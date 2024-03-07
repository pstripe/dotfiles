# TODO: bootstrap process when no git installed on system
# TODO: Install fonts. By some reason alacritty doesn't search it in default paths (.fonts, .local/share/fonts)
# TODO: auto configure MacOS Applications: Alacritty, Zoom
# TODO: add neovim dependencies: lsp, treesitter, ...

CONFIG_DIR = ${HOME}/.config

CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,alacritty git nvim nix fish zellij bottom)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc)

PACKAGES        := bat bottom delta exa fd fish fzf git git-stack neovim nerdfonts nushell ripgrep zellij
PACKAGES        += alacritty monitorcontrol # Requires symlink to /Application on MacOS
PACKAGES        += php phpactor
UNFREE_PACKAGES := zoom-us

.PHONY: configs
configs: ${CONFIG_TARGETS} ${HOME_TARGETS}

# TODO: remove PHONY somehow and add as packages dependency
.PHONY: nix
nix:
	curl -L https://nixos.org/nix/install | sh

.PHONY: packages
packages: configs
	nix profile install $(addprefix nixpkgs#,${PACKAGES})
	NIXPKGS_ALLOW_UNFREE=1 nix profile install --impure $(addprefix nixpkgs#,${UNFREE_PACKAGES})

${CONFIG_DIR}:
	mkdir ${CONFIG_DIR}

${CONFIG_TARGETS}: ${CONFIG_DIR}
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${HOME_TARGETS}:
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(subst .,,$(notdir $@)) $@
