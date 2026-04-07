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
  work:         [vault]
}

const PACKAGES_META = {
  bat:                        nix
  deno:                       nix
  just-lsp:                   nix
  vscode-json-languageserver: nix
  yaml-language-server:       nix
  nix:                        nix # Manage itself
  bottom:                     nix
  choose:                     nix
  eza:                        nix
  fd:                         nix
  fzf:                        nix
  just:                       nix
  pup:                        nix
  ripgrep:                    nix
  sd:                         nix
  yazi:                       nix
  zoxide:                     nix
  protobuf:                   nix
  fish:                       nix
  nushell:                    nix
  helix:                      nix
  php:                        nix
  phpactor:                   nix
  jdk17:                      nix
  gradle:                     nix
  jdt-language-server:        nix
  protoc-gen-go:              nix
  protoc-gen-go-grpc:         nix
  git:                        nix
  cargo:                      nix
  rustc:                      nix
  rustfmt:                    nix
  rust-analyzer:              nix
  go:                         nix
  gopls:                      nix
  delve:                      nix
  golangci-lint-langserver:   nix
  opencode:                   nix
  lazygit:                    nix
  delta:                      nix
  codebook:                   nix
  glow:                       nix
  marksman:                   nix
  alfred: cask
  # alfred: {
  #   manager: brew
  #   options: [--case]
  #   updatable: false
  # }
  firefox: cask
  # firefox: {
  #   manager: brew
  #   options: [--case]
  #   updatable: false
  # }
  mdterm:                cargo
  aerospace:             cask
  ghostty:               cask
  pika:                  cask
  orbstack:              cask
  docker-client:         nix
  docker-compose:        nix
  qemu:                  nix
  vault:                 brew
  colima:                nix
  font-cascadia-code-nf: cask
}

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

def split_by_manager [pkgs: list<string>] {
  mut pkgs_by_manager = {}

  for pkg in $pkgs {
    let manager = $PACKAGES_META | get $pkg

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

  ^brew update
  ^brew outdated --cask
  ^brew upgrade --cask ...$casks
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
