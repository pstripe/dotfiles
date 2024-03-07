# FIXME: bootstrap process when no git installed on system
# FIXME: Install fish configs before first fish run (fish creates config directory by itself and make file
# thinks it is already created)
# FIXME: Configure PATH - add .nix-profile/bin, to be able to start after reboot
# TODO: Install fonts. By some reason alacritty doesn't search it in default paths (.fonts,
# .share/fonts)
# TODO: auto configure MacOS Applications: Alacritty, Zoom
# TODO: add neovim dependencies: lsp, treesitter, ...
# TODO: configure fish as login shell somehow (zshrc with fish -l on mac or chsh)

CONFIG_DIR = ${HOME}/.config

NIX_TARGET     = $(addprefix ${CONFIG_DIR}/,nix)
CONFIG_TARGETS = $(addprefix ${CONFIG_DIR}/,alacritty git nvim fish zellij bottom)
CONFIG_TARGETS = $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   = $(addprefix ${HOME}/,.editorconfig)

PACKAGES        := alacritty bat bottom delta exa fd fish fzf git git-stack neovim nerdfonts nushell ripgrep zellij
PACKAGES        += php phpactor
UNFREE_PACKAGES := zoom-us

.PHONY: configs
configs: ${CONFIG_TARGETS} ${NIX_TARGET} ${HOME_TARGETS}

# FIXME: not works
# TODO: remove PHONY somehow and add as packages dependency
.PHONY: nix
nix:
	sh <(curl -L https://nixos.org/nix/install)

.PHONY: packages
packages: ${NIX_TARGET}
	nix profile install $(addprefix nixpkgs#,${PACKAGES})
	NIXPKGS_ALLOW_UNFREE=1 nix profile install --impure $(addprefix nixpkgs#,${UNFREE_PACKAGES})

${CONFIG_DIR}:
	mkdir ${CONFIG_DIR}

${CONFIG_TARGETS} ${NIX_TARGET}: ${CONFIG_DIR}
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${HOME_TARGETS}:
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(subst .,,$(notdir $@)) $@
