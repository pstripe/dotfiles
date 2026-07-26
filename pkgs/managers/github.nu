export const MANAGER = "github"
export const DEPS = ["ouch"]

export def install [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {install_impl $in}
}

def install_impl [pkg: record] {
  print $"Installing ($pkg.name)..."

  # download
  let asset = http get --headers {Authorization: $pkg.managers.token} https://api.github.com/repos/($pkg.managers.repo)/releases/tags/($pkg.managers.version)
    | get assets
    | where name has $pkg.managers.dist.filename_contains and name not-has "sha"
    | get browser_download_url
    | get 0

  let dist_dir = ["/tmp/pkg-dist/", $pkg.managers.repo, $pkg.managers.version] | path join
  let dist_path = [$dist_dir, ($asset | path basename)] | path join
  let dist_unpack_dir = [$dist_dir, "dist"] | path join

  if not ($dist_path | path exists) {
    mkdir $dist_dir

    http get $asset | save --progress $dist_path
  }

  # unpack
  ^ouch decompress --quiet --yes --dir $dist_unpack_dir $dist_path

  # install
  for file in ($pkg.managers.dist.files) {
    let src = glob ($dist_unpack_dir)/**/($file.source) | get 0

    print $"Copying ($src) to ($env.HOME)/.local/($file.dest)..."
    cp --update $src $"($env.HOME)/.local/($file.dest)"
  }
}

export def check_updates [pkgs: table] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {check_updates_impl $in}
}

def check_updates_impl [pkg: record] {
  let newer_versions = http get --headers {Authorization: $pkg.managers.token} https://api.github.com/repos/($pkg.managers.repo)/releases
    | where tag_name > $pkg.managers.version
    | get tag_name

  if ($newer_versions | is-not-empty) {
    print $"($pkg) has newer versions:"
    print $newer_versions
  }
}
