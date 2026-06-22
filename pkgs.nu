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
  $pkgs | update_pkgs
}

def "main update" [...pkgs: string] {
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

def split_by_manager [pkgs: list<string>]: nothing -> table<pkg:string, manager:string> {
  $pkgs | each { {pkg: $in manager: (manager $in)} }
}

def install []: list<string> -> nothing {
  let $pkgs_by_manager = split_by_manager $in

# TODO: path rich packages instead of separate pkgs list string and whole data
  brew   install ($pkgs_by_manager | where manager == brew   | get pkg)
  cask   install ($pkgs_by_manager | where manager == cask   | get pkg)
  docker install ($pkgs_by_manager | where manager == docker | get pkg) $env_data
  nix    install ($pkgs_by_manager | where manager == nix    | get pkg)
  uv     install ($pkgs_by_manager | where manager == uv     | get pkg) $env_data
  github install ($pkgs_by_manager | where manager == github | get pkg) $env_data
}

def update_pkgs []: list<string> -> nothing {
  let pkgs_by_manager = split_by_manager $in

  # TODO: path rich packages instead of separate pkgs list string and data
  brew update ($pkgs_by_manager | where manager == brew | get pkg)
  cask update ($pkgs_by_manager | where manager == cask | get pkg) $env_data
  nix  update ($pkgs_by_manager | where manager == nix  | get pkg)
  uv   update ($pkgs_by_manager | where manager == uv   | get pkg) $env_data

  # TODO: update for github relases
  # TODO: update for docker
}

def check_updates []: list<string> -> nothing {
  let pkgs_by_manager = split_by_manager $in

  # TODO: path rich packages instead of separate pkgs list string and data
  brew   check_updates
  cask   check_updates
  github check_updates ($pkgs_by_manager | where manager == github | get pkg) $env_data

  # TODO: check updates for docker
  # TODO: check updates for nix
}
