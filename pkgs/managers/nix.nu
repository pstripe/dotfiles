export const MANAGER = "nix"
export const DEPS = ["nix"]

export def install [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  let pkg_names = $pkgs | each {'nixpkgs#' + $in}

  ^nix profile add ...$pkg_names
}

export def update [pkgs: list<string>] {
  if ($pkgs | is-empty) {
    return
  }

  ^nix profile upgrade ...$pkgs
  ^nix profile wipe-history --older-than 30d
  ^nix store gc
}
