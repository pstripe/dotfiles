# Dotifiles

## Bootstrapping
### MacOS
First of all you need to get `make` and `git` executables if they are missed.
```sh
xcode-select --install
```

Next cloning this repo. You need to add machine's public SSH key to Github first.
```sh
git clone git@github.com:pstripe/dotfiles.git .dotfiles
```

Then
```sh
cd .dotfiles
make nix
make packages
make configs
```

## TODO
1. Add bootstrapping script.
2. Bootstrap neovim plugins
3. Add script for auto commit+push. Configure auto commit+push