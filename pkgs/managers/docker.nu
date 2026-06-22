export const MANAGER = "docker"
export const DEPS = ["docker-client"]

export def install [pkgs: list<string>, env_data: any] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {install_impl $in $env_data}
}

def install_impl [pkg: string, env_data: any] {
  print $"Installing ($pkg)..."

  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  let image = [$pkg_meta.image $pkg_meta.version] | str join ':'

  # download
  ^docker pull $image
  ^docker tag $image $"pkg-manager/($pkg):current"
}
