# Dotfiles

## Bootstrapping
### MacOS
Getting `make` and `git` executables if they are missed.
```sh
xcode-select --install
```

Generation then adding SSH keys to Github.
```sh
ssh-keygen -t ed25519
```

Cloning the repo.
```sh
git clone git@github.com:pstripe/dotfiles.git .dotfiles
```

Bootstrapping environment.
```sh
cd .dotfiles
make nix
make packages
```

## TODO
1. Add bootstrapping script (if no git available).
2. Add script for auto commit+push. Configure auto commit+push

# Package Manager V2
The idea is to implement a simple, mostly binary package manager with cross-platform support for **macOS** and **Gentoo Linux**.

To achieve this, we need to make the package manager cross-platform, which means making it slightly more complex than a simple Makefile or Justfile.

What we will do: separate package manager's scripts and packages' declaration.

## Declaring Packages
To declare packages, we will use TOML file format as more simple than YAML and more human readable than JSON.

We want packages to be declared only, and not have any complex scripts near it. So, we do not consider using any scripting languages for package declarations.

### Package
The base idea is similar to any other package manager. We have separate files describing specific packages, their dependencies, optional build rules, and underlying source customisations (specific prefixes, suffixes, custom tags, etc.).

Required features:
* Disable upgrades for source. Some packages upgrade themselves, so we do not need to do it on our own.

### Environment
Environment is a list of tracked packages I want to be managed by my _package manager_. Just for bootstrap and auto upgrades.

## Package Manager
Start with Nushell scripting language because it has builtin support of TOML. And I personally like it.

It is possible to wrap these scripts with Justfile to have a more convenient interface.

### Features
* `bootstrap` itself and core requirements: install Nix, Brew, Rust with Cargo, etc.
* `install <package>`. _Should it add package to `environment.toml`?_
* `upgrade` everything from `environment.toml`,
* `uninstall <package>`. _Should it add package to `environment.toml`?_
* `list` installed packages. Simply show the contents of `environment.toml`.
* _optional_ `add` a new package command which starts the editor with package template

### Sources list
* brew bottles (macOS)
* brew casks (macOS)
* Nixpkgs (macOS)
* portage (Gentoo Linux)
* Cargo (macOS/Gentoo)
* GitHub Releases
