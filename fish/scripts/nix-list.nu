#!/usr/bin/env nu

nix profile list
  | lines
  | split column ' '
  | select column2 column4
  | rename app version
  | update app { |x| $x.app | split row '.' | last }
  | update version { |x| $x.version | parse -r '-(\d+\.\d+\.\d+)(?:-.*)?' | get -i capture0.0 }
