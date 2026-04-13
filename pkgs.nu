#!/usr/bin/env nu

const USES = {
  ai:           [opencode]
  base:         [bat bottom choose eza fd fzf just pup ripgrep sd yazi zoxide]
  docker:       [colima docker-client docker-compose qemu]
  editors:      [helix]
  git:          [git lazygit delta]
  go:           [go gopls delve golangci-lint-langserver]
  java:         [jdk17 gradle jdt-language-server]
  lsp:          [gopls golangci-lint-langserver jdt-language-server marksman codebook phpactor deno just-lsp vscode-json-languageserver yaml-language-server]
  markdown:     [mdterm glow marksman codebook]
  php:          [php phpactor]
  pkg-managers: [nix]
  protobuf:     [protobuf protoc-gen-go protoc-gen-go-grpc]
  rust:         [cargo rustc rustfmt rust-analyzer]
  shells:       [fish nushell]
  ui:           [aerospace ghostty pika orbstack font-cascadia-code-nf alfred firefox]
  disk-utils:   [mole]
  work:         [vault]
}

const PACKAGES_META: table<package:string, config:record<manager:string>> = [
  [package, config];
  [bat, {manager: nix}]
  [deno, { manager: nix }]
  [just-lsp, { manager: nix }]
  [vscode-json-languageserver, { manager: nix }]
  [yaml-language-server, { manager: nix }]
  [nix, { manager: nix }]
  [bottom, { manager: nix }]
  [choose, { manager: nix }]
  [eza, { manager: nix }]
  [fd, { manager: nix }]
  [fzf, { manager: nix }]
  [just, { manager: nix }]
  [pup, { manager: nix }]
  [mole, { manager: brew }]
  [ripgrep, { manager: nix }]
  [sd, { manager: nix }]
  [yazi, { manager: nix }]
  [zoxide, { manager: nix }]
  [protobuf, { manager: nix }]
  [fish, { manager: nix }]
  [nushell, { manager: nix }]
  [helix, { manager: nix }]
  [php, { manager: nix }]
  [phpactor, { manager: nix }]
  [jdk17, { manager: nix }]
  [gradle, { manager: nix }]
  [jdt-language-server, { manager: nix }]
  [protoc-gen-go, { manager: nix }]
  [protoc-gen-go-grpc, { manager: nix }]
  [git, { manager: nix }]
  [cargo, { manager: nix }]
  [rustc, { manager: nix }]
  [rustfmt, { manager: nix }]
  [rust-analyzer, { manager: nix }]
  [go, { manager: nix }]
  [gopls, { manager: nix }]
  [delve, { manager: nix }]
  [golangci-lint-langserver, { manager: nix }]
  [opencode, { manager: nix }]
  [lazygit, { manager: nix }]
  [delta, { manager: nix }]
  [codebook, { manager: nix }]
  [glow, { manager: nix }]
  [marksman, { manager: nix }]
  [alfred, { manager: cask, updatable: false}]
  [firefox, { manager: cask, updatable: false}]
  [mdterm, { manager: cargo }]
  [aerospace, { manager: cask }]
  [ghostty, { manager: cask }]
  [pika, { manager: cask }]
  [orbstack, { manager: cask }]
  [docker-client, { manager: nix }]
  [docker-compose, { manager: nix }]
  [qemu, { manager: nix }]
  [vault, { manager: brew }]
  [colima, { manager: nix }]
  [font-cascadia-code-nf, { manager: cask }]
]

def main [] { }

def "main list-uses" [] {
  $USES | columns
}

def "main install" [use: string] {
  install_pkgs ($USES | get $use)
}

def "main update" [use: string] {
  update_pkgs ($USES | get $use)
}

def "main update-all" [] {
  let all = $USES | values | flatten

  update_pkgs $all
}

def pkg_config [pkg: string] {
  $PACKAGES_META | where package == $pkg | get 0.config
}

def split_by_manager [pkgs: list<string>] {
  mut pkgs_by_manager = {}

  for pkg in $pkgs {
    let manager = pkg_config $pkg | get manager

    let row = $pkgs_by_manager | get --optional $manager | default [] | append $pkg

    $pkgs_by_manager = $pkgs_by_manager | upsert $manager $row
  }

  $pkgs_by_manager
}

def install_pkgs [pkgs: list<string>] {
  let $pkgs_by_manager = split_by_manager $pkgs

  install_brew ($pkgs_by_manager | get --optional brew | default [])
  install_brew_casks ($pkgs_by_manager | get --optional cask | default [])
  install_cargo ($pkgs_by_manager | get --optional cargo | default [])
  install_nix ($pkgs_by_manager | get --optional nix | default [])
}

def update_pkgs [pkgs: list<string>] {
  let $pkgs_by_manager = split_by_manager $pkgs

  update_brew ($pkgs_by_manager | get --optional brew | default [])
  update_brew_casks ($pkgs_by_manager | get --optional cask | default [])
  update_cargo ($pkgs_by_manager | get --optional cargo | default [])
  update_nix ($pkgs_by_manager | get --optional nix | default [])
}

# install section
def install_brew [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew update
  ^brew install ...$pkgs
}

def install_brew_casks [casks: list<string>] {
  if ($casks | is-empty) {
    return
  }

  ^brew update
  ^brew install --cask ...$casks
}

def install_cargo [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  cargo install ...$pkgs
}

def install_nix [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  let pkg_names = $pkgs | each {|pkg| 'nixpkgs#' + $pkg }

  ^nix profile add ...$pkg_names
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

  let $updatable_casks = $casks | where {|cask| pkg_config $cask | get --optional updatable | default true}

  ^brew update
  ^brew outdated --cask
  ^brew upgrade --cask ...$updatable_casks
}

def update_cargo [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  cargo install ...$pkgs
}

def update_nix [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^nix profile upgrade ...$pkgs
  ^nix profile wipe-history --older-than 30d
  ^nix store gc
}
