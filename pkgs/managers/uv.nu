export const MANAGER = "uv"
export const DEPS = ["uv"]

export def install [pkgs: list<string>, env_data: any] {
  install_impl $pkgs $env_data
}

export def update [pkgs: list<string>, env_data: any] {
  # BUG: uv has a bug: it cannot `upgrade` packages with extras (`semble[mcp]`), using `install` instead
  install_impl $pkgs $env_data
}

def install_impl [pkgs: list<string>, env_data: any] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {|pkg|
    let pkg_meta = $env_data | where name == $pkg | get 0.managers
    let name = $pkg_meta.package | default $pkg

    ^uv tool install $"($name)==($pkg_meta.version)"
  }
}
