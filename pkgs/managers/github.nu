export const MANAGER = "github"
export const DEPS = ["ouch"]

export def install [pkgs: list<string>, env_data: any] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {install_impl $in $env_data}
}

def install_impl [pkg: string, env_data: any] {
  print $"Installing ($pkg)..."

  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  # download
  let asset = http get --headers {Authorization: $pkg_meta.token} https://api.github.com/repos/($pkg_meta.repo)/releases/tags/($pkg_meta.version)
    | get assets
    | where name has $pkg_meta.dist.filename_contains and name not-has "sha"
    | get browser_download_url
    | get 0

  let dist_dir = ["/tmp/pkg-dist/", $pkg_meta.repo, $pkg_meta.version] | path join
  let dist_path = [$dist_dir, ($asset | path basename)] | path join
  let dist_unpack_dir = [$dist_dir, "dist"] | path join

  if not ($dist_path | path exists) {
    mkdir $dist_dir

    http get $asset | save --progress $dist_path
  }

  # unpack
  ^ouch decompress --quiet --yes --dir $dist_unpack_dir $dist_path

  # install
  for file in ($pkg_meta.dist.files) {
    let src = glob ($dist_unpack_dir)/**/($file.source) | get 0

    print $"Copying ($src) to ($env.HOME)/.local/($file.dest)..."
    cp --update $src $"($env.HOME)/.local/($file.dest)"
  }
}

export def check_updates [pkgs: list<string>, env_data: any] {
  if ($pkgs | is-empty) {
    return
  }

  $pkgs | each {check_updates_impl $in $env_data}
}

def check_updates_impl [pkg: string, env_data: any] {
  let pkg_meta = $env_data | where name == $pkg | get 0.managers

  let newer_versions = http get --headers {Authorization: $pkg_meta.token} https://api.github.com/repos/($pkg_meta.repo)/releases
    | where tag_name > $pkg_meta.version
    | get tag_name

  if ($newer_versions | is-not-empty) {
    print $"($pkg) has newer versions:"
    print $newer_versions
  }
}
