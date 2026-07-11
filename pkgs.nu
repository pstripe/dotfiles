#!/usr/bin/env nu

use pkgs/managers/brew.nu
use pkgs/managers/cask.nu
use pkgs/managers/docker.nu
use pkgs/managers/github.nu
use pkgs/managers/nix.nu
use pkgs/managers/uv.nu

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
}

def main [] { }

def "main list-uses" [] {
  open pkgs/meta/*.toml | select name tags | flatten tags | group-by tags
}

def "main install-all" [] {
  $env_data | install
}

def "main install" [...names: string] {
  $env_data | where name in [...$names] | install
}

def "main check-updates" [] {
  $env_data | get name | check_updates
}

def "main update-all" [
  --skip: string
] {
  let $pkgs = $env_data | where name != $skip

  $pkgs | check_updates
  $pkgs | update_pkgs
}

def "main update" [...names: string] {
  let pkgs = $env_data | where name in [...$names]

  $pkgs | check_updates
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

def install []: table -> nothing {
  brew   install ($in | where managers.name == brew)
  cask   install ($in | where managers.name == brew-cask)
  docker install ($in | where managers.name == docker)
  nix    install ($in | where managers.name == nix)
  uv     install ($in | where managers.name == uv)
  github install ($in | where managers.name == github)
}

def update_pkgs []: table -> nothing {
  brew update ($in | where managers.name == brew)
  cask update ($in | where managers.name == brew-cask)
  nix  update ($in | where managers.name == nix)
  uv   upd    ($in | where managers.name == uv)

  # TODO: update for github relases
  # TODO: update for docker
}

def check_updates []: table -> nothing {
  brew   check_updates
  cask   check_updates
  github check_updates ($in | where managers.name == github)

  # TODO: check updates for docker
  # TODO: check updates for nix
}
