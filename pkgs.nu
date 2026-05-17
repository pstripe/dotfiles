#!/usr/bin/env nu

# WARN: globals
let env_file = open pkgs/environment.toml
let pkgs_meta = open pkgs/meta/*.toml
let env_data = env

def main [] { }

def "main list-uses" [] {
  $pkgs_meta | select name tags | flatten tags | group-by tags #--prune
}

def "main install" [pkgs: list<string>] {
  install_pkgs $pkgs
}

def "main update-all" [
  --skip: string
] {
  update_pkgs ($env_data | where name != $skip | get name)
}

def env [] {
  $env_file.packages
    | wrap name
    | join ($pkgs_meta) name
    | update managers {|r| $r.managers | join $env_file.managers name | sort-by --reverse priority | get 0}
}

def manager [pkg: string] {
  try {
    $env_data | where name == $pkg | get 0.managers.name
  } catch {
    error make {
      msg: $"($pkg) could not be found"
    }
  }
}

def config [field:string]: string -> any {
  manager $in | get --optional $field
}

def split_by_manager [pkgs: list<string>] {
  mut pkgs_by_manager = {}

  for pkg in $pkgs {
    let manager = manager $pkg

    let row = $pkgs_by_manager | get --optional $manager | default [] | append $pkg

    $pkgs_by_manager = $pkgs_by_manager | upsert $manager $row
  }

  $pkgs_by_manager
}

def install_pkgs [pkgs: list<string>] {
  let $pkgs_by_manager = split_by_manager $pkgs

  install_brew ($pkgs_by_manager | get --optional brew | default [])
  install_brew_casks ($pkgs_by_manager | get --optional cask | default [])
  install_docker_images ($pkgs_by_manager | get --optional docker | default [])
  install_github_releases ($pkgs_by_manager | get --optional github | default [])
  install_nix ($pkgs_by_manager | get --optional nix | default [])
}

def update_pkgs [pkgs: list<string>] {
  let pkgs_by_manager = split_by_manager $pkgs

  update_brew ($pkgs_by_manager | get --optional brew | default [])
  update_brew_casks ($pkgs_by_manager | get --optional cask | default [])
  install_docker_images ($pkgs_by_manager | get --optional docker | default [])
  install_github_releases ($pkgs_by_manager | get --optional github | default [])
  update_nix ($pkgs_by_manager | get --optional nix | default [])
}

# install section
# Depends on `brew`
def install_brew [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew update
  ^brew install ...$pkgs
}

# Depends on `brew`
def install_brew_casks [casks: list<string>] {
  if ($casks | is-empty) {
    return
  }

  ^brew update
  ^brew install --cask ...$casks
}

# Depends on `nix`
def install_nix [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  let pkg_names = $pkgs | each {|pkg| 'nixpkgs#' + $pkg }

  ^nix profile add ...$pkg_names
}

# Depends on `docker-client`
def install_docker_images [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {|pkg| _install_docker_image $pkg}
}

def _install_docker_image [pkg: string] {
  print $"Installing ($pkg)..."

  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  let image = [$pkg_meta.image $pkg_meta.version] | str join ':'

  # download
  ^docker pull $image
  ^docker tag $image $"pkg-manager/($pkg):current"
}

# Depends on `ouch`
def install_github_releases [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {|pkg| _install_github_release $pkg}
}

def _install_github_release [pkg: string] {
  print $"Installing ($pkg)..."

  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  # download
  # TODO: auth
  let asset = http get https://api.github.com/repos/($pkg_meta.repo)/releases/tags/($pkg_meta.version)
    | get assets
    | where name has $pkg_meta.dist.filename_contains and name not-has "sha"
    | get browser_download_url
    | get 0

  let dist_dir = ["/tmp/pkg-dist/", $pkg_meta.repo, $pkg_meta.version] | path join
  let dist_path = [$dist_dir, ($asset | path basename)] | path join
  let dist_unpack_dir = [$dist_dir, "dist"] | path join

  if not ($dist_path | path exists) {
    mkdir $dist_dir

    http get $asset | save --progress $dist_path
  }

  # unpack
  ^ouch decompress --quiet --yes --dir $dist_unpack_dir $dist_path

  # install
  for file in ($pkg_meta.dist.files) {
      print $"Copying ($dist_unpack_dir)/($file.source) to ($env.HOME)/.local/($file.dest)..."
      cp $"($dist_unpack_dir)/($file.source)" $"($env.HOME)/.local/($file.dest)"
  }
}

# update section
def update_brew [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew update
  ^brew outdated
  ^brew upgrade ...$pkgs
}

def update_brew_casks [casks: list<string>] {
  if ($casks | is-empty) {
    return
  }

  let $updatable_casks = $casks | where {|cask| $cask | config updatable | default true}

  ^brew update
  ^brew outdated --cask
  ^brew upgrade --cask ...$updatable_casks
}

def update_github_releases [pkgs: list<string>] {
  print "Update from Github Releases is not implemented"
}

def update_nix [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^nix profile upgrade ...$pkgs
  ^nix profile wipe-history --older-than 30d
  ^nix store gc
}
