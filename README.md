# Dotifiles

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
