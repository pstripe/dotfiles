#!/usr/bin/env nu

# WARN: globals
let env_data = do {
  let env_file: record<name:string, packages:list<string>, managers:table> = open pkgs/environment.toml

  $env_file.packages
    | each { open $"pkgs/meta/($in).toml" }
    | update managers {|r|
        $r.managers
        | join $env_file.managers name
        | sort-by --reverse priority
        | get 0
      }
    | inspect
}

def main [] { }

def "main list-uses" [] {
  open pkgs/meta/*.toml | select name tags | flatten tags | group-by tags #--prune
}

def "main install" [...pkgs: string] {
  $pkgs | install
}

def "main check-updates" [] {
  $env_data | get name | check_updates
}

def "main update-all" [
  --skip: string
] {
  let $pkgs = $env_data | where name != $skip | get name

  $pkgs | check_updates

  input "Proceed? (press enter) > "

  $pkgs | update_pkgs
}

def "main update" [...pkgs: string] {
  $pkgs | check_updates

  input "Proceed? (press enter) > "

  $pkgs | update_pkgs
}

def manager [pkg: string] {
  try {
    $env_data | where name == $pkg | get 0.managers.name
  } catch {
    error make {
      msg: $"($pkg) could not be found in environment.toml"
    }
  }
}

def config [field:string]: string -> any {
  manager $in | get --optional $field
}

def split_by_manager [pkgs: list<string>]: nothing -> table<pkg:string, manager:string> {
  $pkgs | each { {pkg: $in manager: (manager $in)} }
}

def install []: list<string> -> nothing {
  let $pkgs_by_manager = split_by_manager $in

  install_brew ($pkgs_by_manager | where manager == brew | get pkg)
  install_brew_casks ($pkgs_by_manager | where manager == cask | get pkg)
  install_docker_images ($pkgs_by_manager | where manager == docker | get pkg)
  install_github_releases ($pkgs_by_manager | where manager == github | get pkg)
  install_nix ($pkgs_by_manager | where manager == nix | get pkg)
  install_uv ($pkgs_by_manager | where manager == uv | get pkg)
}

def update_pkgs []: list<string> -> nothing {
  let pkgs_by_manager = split_by_manager $in

  update_brew ($pkgs_by_manager | where manager == brew | get pkg)
  update_brew_casks ($pkgs_by_manager | where manager == cask | get pkg)
  # TODO: update for github relases
  # TODO: update for docker
  update_nix ($pkgs_by_manager | where manager == nix | get pkg)
  update_uv ($pkgs_by_manager | where manager == uv | get pkg)
}

def check_updates []: list<string> -> nothing {
  let pkgs_by_manager = split_by_manager $in

  check_updates_brew ($pkgs_by_manager | where manager == brew | get pkg)
  check_updates_brew_casks ($pkgs_by_manager | where manager == cask | get pkg)
  check_updates_github_releases ($pkgs_by_manager | where manager == github | get pkg)
  # TODO: check updates for docker
  # TODO: check updates for nix
}

# install section
# Depends on `brew`
def install_brew [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  # TODO: add taps

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

  let pkg_names = $pkgs | each {'nixpkgs#' + $in}

  ^nix profile add ...$pkg_names
}

# Depends on `docker-client`
def install_docker_images [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {_install_docker_image $in}
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

  $pkgs | each {_install_github_release $in}
}

def _install_github_release [pkg: string] {
  print $"Installing ($pkg)..."

  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  # download
  let asset = http get --headers {Authorization: $pkg_meta.token} https://api.github.com/repos/($pkg_meta.repo)/releases/tags/($pkg_meta.version)
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
    let src = glob ($dist_unpack_dir)/**/($file.source) | get 0

    print $"Copying ($src) to ($env.HOME)/.local/($file.dest)..."
    cp --update $src $"($env.HOME)/.local/($file.dest)"
  }
}

# Depends on uv
def install_uv [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {|pkg|
    let pkg_meta = $env_data | where name == $pkg | get 0.managers
    let name = $pkg_meta.package | default $pkg

    ^uv tool install $"($name)==($pkg_meta.version)"
  }
}

# update section
def update_brew [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew upgrade ...$pkgs
}

def update_brew_casks [casks: list<string>] {
  if ($casks | is-empty) {
    return
  }

  let $updatable_casks = $casks | where {|cask| $cask | config updatable | default true}

  ^brew upgrade --cask ...$updatable_casks
}

def update_nix [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^nix profile upgrade ...$pkgs
  ^nix profile wipe-history --older-than 30d
  ^nix store gc
}

def update_uv [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {|pkg|
    let pkg_meta = $env_data | where name == $pkg | get 0.managers
    let name = $pkg_meta.package | default $pkg

    ^uv tool upgrade $"($name)==($pkg_meta.version)"
  }
}

# check_updates section
def check_updates_brew [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew update
  ^brew outdated
}

def check_updates_brew_casks [casks: list<string>] {
  if ($casks | is-empty) {
    return
  }

  ^brew update
  ^brew outdated --cask
}

def check_updates_github_releases [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {_check_updates_github_release $in}
}

def _check_updates_github_release [pkg: string] {
  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  let newer_versions = http get --headers {Authorization: $pkg_meta.token} https://api.github.com/repos/($pkg_meta.repo)/releases
    | where tag_name > $pkg_meta.version
    | get tag_name

  if ($newer_versions | is-not-empty) {
    print $"($pkg) has newer versions:"
    print $newer_versions
  }
}
