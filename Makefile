# TODO: Fix unexisting dependencies breaks installation process

CONFIG_DIR = ${HOME}/.config

backup_existing_data = if [[ -e $(1) && ! -h $(1) ]]; then mv $(1) $(1).old ; fi

configs: alacritty neovim fish nix zellij bottom

.PHONY: env
env:
	# TODO: application list

update:
	git pull origin main


.PHONY: alacrytty_bkp
alacritty_bkp:
	$(call backup_existing_data,${CONFIG_DIR}/alacritty)

alacritty: alacritty_bkp
	echo "Installing alacritty dotfiles"
	ln -s ${CURDIR}/alacritty/ ${CONFIG_DIR}

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

