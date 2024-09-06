# TODO: Install fonts. By some reason alacritty doesn't search it in default paths (.fonts, .local/share/fonts)
# TODO: auto configure MacOS Applications: Alacritty, Zoom
# TODO: add `clean` target

CONFIG_DIR = ${HOME}/.config

EXTRA_CONFIGS  := $(addprefix ${CONFIG_DIR}/,helix tmux zellij alacritty)
CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,aerospace bat git nvim nix fish bottom wezterm lazygit yazi)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,karabiner)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc)

ENV_PACKAGES    := bat bottom delta eza fd sd fish jq git neovim nushell nnn ripgrep zstd lazygit yazi
ENV_PACKAGES    += nix # Manage itself
BREW_PACKAGES   := alfred monitorcontrol karabiner-elements wezterm zoom firefox
CASK_PACKAGES   := docker
DEV_PACKAGES    := php phpactor
# go-tools: staticcheck
DEV_PACKAGES    += go gopls go-tools delve
DEV_PACKAGES    += cargo rustc rustfmt rust-analyzer
DEV_PACKAGES    += cmake clang

.PHONY: configs
configs: ${CONFIG_TARGETS} ${HOME_TARGETS}

# TODO: remove PHONY somehow and add as packages dependency
.PHONY: nix
nix:
	curl -L https://nixos.org/nix/install | sh

.PHONY: update
update:
	nix profile upgrade '.*'
	nix profile wipe-history --older-than 30d
	nix store gc
	brew update
	brew upgrade
	brew autoremove
	brew cleanup

.PHONY: env-packages
env-packages: configs # TODO: depends on nix
	nix profile install $(addprefix nixpkgs#,${ENV_PACKAGES})

.PHONY: dev-packages
dev-packages: configs
	nix profile install $(addprefix nixpkgs#,${DEV_PACKAGES})

.PHONY: brew-packages
brew-packages: configs
	brew install ${BREW_PACKAGES}
	brew install --cask ${CASK_PACKAGES}

.PHONY: packages
packages: env-packages gui-packages dev-packages unfree-packages

${CONFIG_DIR}:
	mkdir ${CONFIG_DIR}

${CONFIG_TARGETS}: ${CONFIG_DIR}
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${EXTRA_CONFIGS}: ${CONFIG_DIR}
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${HOME_TARGETS}:
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(subst .,,$(notdir $@)) $@
