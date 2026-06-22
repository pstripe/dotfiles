export const MANAGER = "cask"
export const DEPS = ["brew"]

export def install [casks: list<string>] {
  if ($casks | is-empty) {
    return
  }

  ^brew update
  ^brew install --cask ...$casks
}

export def update [casks: list<string>, env_data: any] {
  if ($casks | is-empty) {
    return
  }

  let $updatable_casks = $casks | where {|cask| $env_data | where name == $cask | get --optional 0.managers.name.updatable | default true}

  ^brew upgrade --casks ...$updatable_casks
}

export def check_updates [] {
  ^brew update
  ^brew outdated --cask
}
