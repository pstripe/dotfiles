export const MANAGER = "brew"
export const DEPS = ["brew"]

export def install [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  # TODO: add taps

  ^brew update
  ^brew install ...($pkgs | get name)
}

export def update [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew upgrade --formulae ...($pkgs | get name)
}

export def check_updates [] {
  ^brew update
  ^brew outdated --formulae
}
