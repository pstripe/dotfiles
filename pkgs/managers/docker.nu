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

export def check_updates [pkgs: table] {
  $pkgs | each {|pkg|
    let img = if ($pkg.managers.image | str contains "/")  {
      $pkg.managers.image
    } else {
      $"library/($pkg.managers.image)"
    }

    let tags = http get https://registry.hub.docker.com/v2/repositories/($img)/tags?page_size=20
      | get results
      | where name =~ $pkg.managers.version_re
      | get name

    {
      name: $pkg.name
      cur: $pkg.managers.version
      tags: $tags
    }
  }
}
