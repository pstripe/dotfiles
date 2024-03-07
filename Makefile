CONFIG_DIR = ${HOME}/.config

NIX_TARGET     = $(addprefix ${CONFIG_DIR}/,nix)
CONFIG_TARGETS = $(addprefix ${CONFIG_DIR}/,alacritty nvim fish zellij bottom)
HOME_TARGETS   = $(addprefix ${HOME}/,.editorconfig)

# TODO: auto configure MacOS Applications: Alacritty, Zoom
# TODO: add neovim dependencies: lsp, treesitter, ...
PACKAGES        := alacritty bat bottom delta exa fd fish fzf git git-stack neovim nerdfonts nushell ripgrep zellij
PACKAGES        += php phpactor
UNFREE_PACKAGES := zoom-us

.PHONY: configs
configs: ${CONFIG_TARGETS} ${NIX_TARGET} ${HOME_TARGETS}

.PHONY: nix
nix:
	sh <(curl -L https://nixos.org/nix/install)

.PHONY: packages
packages: env ${NIX_TARGET}
	nix profile install $(addprefix nixpkgs#,${PACKAGES})
	NIXPKGS_ALLOW_UNFREE=1 nix profile install --impure $(addprefix nixpkgs#,${UNFREE_PACKAGES})

${CONFIG_TARGETS} ${NIX_TARGET}:
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${HOME_TARGETS}:
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(subst .,,$(notdir $@)) $@