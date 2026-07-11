export const MANAGER = "uv"
export const DEPS = ["uv"]

export def install [pkgs: table] {
  install_impl $pkgs
}

export def upd [pkgs: table] {
  # BUG: uv has a bug: it cannot `upgrade` packages with extras (`semble[mcp]`), using `install` instead
  install_impl $pkgs
}

def install_impl [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | update managers {|row| $row.managers | default $row.name package } | each {
    ^uv tool install $"($in.managers.package)==($in.managers.version)"
  }
}
