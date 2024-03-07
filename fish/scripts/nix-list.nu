#!/usr/bin/env nu

let version = (nix --version | parse -r '(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)' | into record)

mut table = {};

if ($version.major >= '2') and ($version.minor >= '18') {
  $table = (
    nix profile list --json
      | from json
      | get elements
      | select attrPath storePaths
  )
} else {
  $table = (
    nix profile list
      | lines
      | split column ' '
      | select column2 column4
  )
}

$table
  | rename app version
  | update app { |x| $x.app | split row '.' | last }
  | update version { |x| $x.version | parse -r ($x.app + '-(.*)') | get -i capture0.0 }
  | print
