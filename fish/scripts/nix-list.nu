#!/usr/bin/env nu

let version = ^nix --version | parse -r '(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)' | into record

if ($version.major < '2') or ($version.minor < '24') {
  [
    "Minimum supported version of Nix is 2.24\n"
    "Actual version is "
    ($version | format pattern "{major}.{minor}.{patch}")
  ] | str join | print -e
}

^nix profile list --json
  | from json
  | get elements
  | transpose
  | select column0 column1.storePaths
  | rename app version
  | update app { |x| $x.app | split row '.' | last }
  | update version { |x| $x.version | parse -r ($x.app + '-(.*)') | get --optional capture0.0 }
