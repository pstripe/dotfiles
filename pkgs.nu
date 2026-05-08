#!/usr/bin/env nu

const BUNDLES = {
  ai:           [opencode]
  base:         [bat bottom choose eza fd fzf just pup ripgrep sd yazi zoxide]
  docker:       [colima docker-client docker-compose qemu]
  editors:      [helix]
  git:          [git lazygit delta]
  go:           [go gopls delve golangci-lint-langserver]
  java:         [jdk17 gradle jdt-language-server]
  lsp:          [gopls golangci-lint-langserver jdt-language-server marksman codebook phpactor deno just-lsp vscode-json-languageserver yaml-language-server]
  markdown:     [mdterm marksman codebook]
  php:          [php phpactor]
  pkg-managers: [nix]
  protobuf:     [protobuf protoc-gen-go protoc-gen-go-grpc]
  shells:       [fish nushell]
  ui:           [aerospace ghostty pika orbstack font-cascadia-code-nf alfred firefox]
  disk-utils:   [mole]
  work:         [vault]
}

const ENVIRONMENT_PLUS_PKG_CONFIG: table<package:string, manager:string, config:record> = [
  [package, manager, config];
  [bat, nix, {}]
  [deno, nix, {}]
  [just-lsp, nix, {}]
  [vscode-json-languageserver, nix, {}]
  [yaml-language-server, nix, {}]
  [nix, nix, {}]
  [bottom, nix, {}]
  [choose, nix, {}]
  [eza, nix, {}]
  [fd, nix, {}]
  [fzf, nix, {}]
  [just, nix, {}]
  [pup, nix, {}]
  [mole, brew, {}]
  [ripgrep, nix, {}]
  [sd, nix, {}]
  [yazi, nix, {}]
  [zoxide, nix, {}]
  [protobuf, nix, {}]
  [fish, nix, {}]
  [nushell, nix, {}]
  [helix, nix, {}]
  [php, nix, {}]
  [phpactor, nix, {}]
  [jdk17, nix, {}]
  [gradle, nix, {}]
  [jdt-language-server, nix, {}]
  [protoc-gen-go, nix, {}]
  [protoc-gen-go-grpc, nix, {}]
  [git, nix, {}]
  [go, nix, {}]
  [gopls, nix, {}]
  [delve, nix, {}]
  [golangci-lint-langserver, nix, {}]
  [opencode, nix, {}]
  [lazygit, nix, {}]
  [delta, nix, {}]
  [codebook, nix, {}]
  [marksman, nix, {}]
  [alfred, cask, { updatable: false}]
  [firefox, cask, { updatable: false}]
  [mdterm, nix, {}]
  [aerospace, cask, {}]
  [ghostty, cask, {}]
  [pika, cask, {}]
  [orbstack, cask, {}]
  [docker-client, nix, {}]
  [docker-compose, nix, {}]
  [qemu, nix, {}]
  [vault, brew, {}]
  [colima, nix, {}]
  [font-cascadia-code-nf, cask, {}]
]

def main [] { }

def "main list-uses" [] {
  $BUNDLES | columns
}

def "main install" [use: string] {
  install_pkgs ($BUNDLES | get $use)
}

def "main update" [use: string] {
  update_pkgs ($BUNDLES | get $use)
}

def "main update-all" [
  --skip: string
] {
  mut all = $BUNDLES | values | flatten

  if $skip != null {
    $all = $all | where $it != $skip
  }

  update_pkgs $all
}

def manager []: string -> string {
  $ENVIRONMENT_PLUS_PKG_CONFIG | where package == $in | get 0.manager
}

def config [field:string]: string -> any {
  $ENVIRONMENT_PLUS_PKG_CONFIG | where package == $in | get 0.config | get --optional $field
}

def split_by_manager [pkgs: list<string>] {
  mut pkgs_by_manager = {}

  for pkg in $pkgs {
    let manager = $pkg | manager

    let row = $pkgs_by_manager | get --optional $manager | default [] | append $pkg

    $pkgs_by_manager = $pkgs_by_manager | upsert $manager $row
  }

  $pkgs_by_manager
}

def install_pkgs [pkgs: list<string>] {
  let $pkgs_by_manager = split_by_manager $pkgs

  install_brew ($pkgs_by_manager | get --optional brew | default [])
  install_brew_casks ($pkgs_by_manager | get --optional cask | default [])
  install_github_releases ($pkgs_by_manager | get --optional github | default [])
  install_nix ($pkgs_by_manager | get --optional nix | default [])
}

def update_pkgs [pkgs: list<string>] {
  let $pkgs_by_manager = split_by_manager $pkgs

  update_brew ($pkgs_by_manager | get --optional brew | default [])
  update_brew_casks ($pkgs_by_manager | get --optional cask | default [])
  update_github_releases ($pkgs_by_manager | get --optional github | default [])
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

# Depends on `ouch`
def install_github_releases [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {|pkg| _install_github_release $pkg}
}

def _install_github_release [pkg: string] {
    let packages: table<package:string, repo:string, archive:record<archive:string, filename_contains:string, install:list<record<source:string, dest:string>>>> = [
      [package, repo, version, archive];
      [mdterm, 'bahdotsh/mdterm', 'v2.0.0', {
        archive: tar.gz
        filename_contains: aarch64-darwin
        install: [
          {
            source: mdterm
            dest: $"($env.HOME)/.local/bin/mdterm"
          }
        ]
      }]
    ]
    let pkg_meta = $packages | where package == $pkg | get 0

    # download
    # TODO: auth
    let assets = http get https://api.github.com/repos/($pkg_meta.repo)/releases/tags/($pkg_meta.version)
      | get assets
      | where name has $pkg_meta.archive.filename_contains and name not-has "sha"
      | get browser_download_url
      | get 0

    let dir = mktemp -d
    let arch_file = $assets | path basename
    let arch_path = $"($dir)/($arch_file)"

    http get --headers {Authorization: '{{_auth}}'} $assets | save --progress $arch_path

    # unpack
    ^ouch decompress --quiet --yes --dir $dir $arch_path

    # install
    let decomp_root = $"($dir)/($arch_file | path parse --extension $pkg_meta.install.archive | get stem)"

    for file in ($pkg_meta.archive.install) {
        print $"Copying ($decomp_root)/($file.source) to ($file.dest)..."
        cp $"($decomp_root)/($file.source)" ($file.dest)
    }

    # cleanup
    rm --recursive $dir
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
