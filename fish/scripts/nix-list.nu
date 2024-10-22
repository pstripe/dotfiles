#!/usr/bin/env nu

let version = (nix --version | parse -r '(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)' | into record)

mut table = {};

if ($version.major >= '2') and ($version.minor >= '24') {
  $table = (
    nix profile list --json
      | from json
      | get elements
      | transpose
      | select column0 column1.storePaths
  )
} else {
  [
    "Minimum supported version of Nix is 2.24\n"
    "Actual version is " (nix --version)
  ] | str join | print -e
}

$table
  | rename app version
  | update app { |x| $x.app | split row '.' | last }
  | update version { |x| $x.version | parse -r ($x.app + '-(.*)') | get -i capture0.0 }
  | print
