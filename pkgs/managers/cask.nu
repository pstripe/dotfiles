export const MANAGER = "cask"
export const DEPS = ["brew"]

export def install [casks: table] {
  if ($casks | is-empty) {
    return
  }

  let names = $casks | %update managers {|row| $row.managers | default $row.name tap} | get managers.tap

  ^brew update
  ^brew install --cask ...$names
}

export def update [casks: table] {
  if ($casks | is-empty) {
    return
  }

  let $updatable_casks = $casks | %update managers {|row| $row.managers | default true updatable} | where managers.updatable == true | get name

  ^brew upgrade --casks ...$updatable_casks
}

export def check_updates [] {
  ^brew update
  ^brew outdated --cask
}
