# gentoo packages list
_self  := 'cargo-binstall'
crates := 'choose mdterm rustic-rs sqlx-cli viu uv'

bootstrap:
    cargo install {{_self}}
    cargo binstall {{crates}}

# TODO: extend "world" file on install
# TODO: add dist specific info to package description toml file. E.g:
# - gentoo
#   - <package_name: ask?>
#     source: cargo
#     source_package_name: {{package}}
install *package:
    cargo binstall {{package}}

# TODO: temp, migrate to pkgs.nu
update:
    #!/usr/bin/env fish
    for pkg in {{_self}} {{crates}}
        just cargo::install $pkg
    end
