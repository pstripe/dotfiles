export const MANAGER = "docker"
export const DEPS = ["docker-client"]

export def install [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {install_impl $in}
}

def install_impl [pkg: record] {
  print $"Installing ($pkg.name)..."

  let image = [$pkg.managers.image $pkg.managers.version] | str join ':'

  # download
  ^docker pull $image
  ^docker tag $image $"pkg-manager/($pkg.name):current"
}
