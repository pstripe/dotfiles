export const MANAGER = "nix"
export const DEPS = ["nix"]

export def install [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  let pkg_names = $pkgs | each {'nixpkgs#' + $in.name}

  ^nix profile add ...$pkg_names
}

export def update [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  ^nix profile upgrade ...($pkgs | get name)
  ^nix profile wipe-history --older-than 30d
  ^nix store gc
}
