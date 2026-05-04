_self    := 'zyedidia/eget'
packages := 'simonmichael/hledger'

bootstrap:
    curl -o eget.sh https://zyedidia.github.io/eget.sh
    (echo "0e64b8a3c13f531da005096cc364ac77835bda54276fedef6c62f3dbdc1ee919  eget.sh" | sha256sum -c --quiet -)
    bash eget.sh
    ./eget {{_self}}
    rm eget eget.sh

install *package:
    eget {{package}}

# TODO: temp, migrate to pkgs.nu
update:
    #!/usr/bin/env fish
    for pkg in {{_self}} {{packages}}
        eget --upgrade-only $pkg
    end
