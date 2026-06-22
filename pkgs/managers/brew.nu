export const MANAGER = "brew"
export const DEPS = ["brew"]

export def install [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  # TODO: add taps

  ^brew update
  ^brew install ...$pkgs
}

export def update [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^brew upgrade --formulae ...$pkgs
}

export def check_updates [] {
  ^brew update
  ^brew outdated --formulae
}
