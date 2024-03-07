# TODO: Fix unexisting dependencies breaks installation process

CONFIG_DIR = ${HOME}/.config

backup_existing_data = if [[ -e $(1) && ! -h $(1) ]]; then mv $(1) $(1).old ; fi

bootstrap: env configs
configs: alacritty neovim fish nix zellij bottom

.PHONY: env
env:
	sh <(curl -L https://nixos.org/nix/install)

	nix profile install nixpkgs#alacritty
	nix profile install nixpkgs#bat
	nix profile install nixpkgs#bottom
	nix profile install nixpkgs#delta
	nix profile install nixpkgs#exa
	nix profile install nixpkgs#fd
	nix profile install nixpkgs#fish
	nix profile install nixpkgs#fzf
	nix profile install nixpkgs#git
	nix profile install nixpkgs#git-stack
	nix profile install nixpkgs#neovim
	nix profile install nixpkgs#nerdfonts
	nix profile install nixpkgs#nushell
	nix profile install nixpkgs#php
	nix profile install nixpkgs#phpactor
	nix profile install nixpkgs#ripgrep
	nix profile install nixpkgs#zellij


.PHONY: alacrytty_bkp
alacritty_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/alacritty)

alacritty: alacritty_bkp
	echo "Installing alacritty dotfiles"
	ln -s ${CURDIR}/alacritty ${CONFIG_DIR}

.PHONY: neovim_bkp
neovim_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/nvim)

neovim: neovim_bkp
	echo "Installing neovim dotfiles"
	ln -s ${CURDIR}/nvim ${CONFIG_DIR}


.PHONY: fish_bkp
fish_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/fish)

fish: fish_bkp
	echo "Installing Fish dotfiles"
	ln -s ${CURDIR}/fish ${CONFIG_DIR}

.PHONY: nix_bkp
nix_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/nix)

nix: nix_bkp
	echo "Installing Nix dotfiles"
	ln -s ${CURDIR}/nix ${CONFIG_DIR}

.PHONY: zellij_bkp
zellij_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/zellij)

zellij: zellij_bkp
	echo "Installing Zellij dotfiles"
	ln -s ${CURDIR}/zellij ${CONFIG_DIR}

.PHONY: bottom_bkp
bottom_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/bottom)

bottom: bottom_bkp
	echo "Installing Bottom dotfiles"
	ln -s ${CURDIR}/bottom ${CONFIG_DIR}

