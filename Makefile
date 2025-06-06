# TODO: add `clean` target

CONFIG_DIR = ${HOME}/.config

EXTRA_CONFIGS  := $(addprefix ${CONFIG_DIR}/,nvim tmux wezterm zellij alacritty)
CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,aerospace bat codebook git ghostty helix nix fish bottom lazygit yazi)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc)

ENV_PACKAGES := bat bottom broot choose codebook eza fd fzf just jq pup ripgrep sd yazi zstd
ENV_PACKAGES += nix # Manage itself
# shell
ENV_PACKAGES += fish nushell
# editor
ENV_PACKAGES += helix neovim
# markdown
ENV_PACKAGES += glow marksman

# brew deps
# Self updatable casks
INSTALLABLE_CASKS := firefox zoom
# Updated by Brew
UPDATABLE_CASKS := aerospace alfred docker font-cascadia-code-nf ghostty pika wezterm

# php
DEV_PACKAGES := php phpactor
# git
DEV_PACKAGES += git lazygit delta
# go
# go-tools: staticcheck
DEV_PACKAGES += go gopls go-tools delve
# rust
DEV_PACKAGES += cargo rustc rustfmt rust-analyzer
# c/c++
DEV_PACKAGES += cmake

.PHONY: configs
configs: ${CONFIG_TARGETS} ${HOME_TARGETS}

# TODO: remove PHONY somehow and add as packages dependency
.PHONY: nix
nix:
	curl -L https://nixos.org/nix/install | sh

.PHONY: update
update:
	nix profile upgrade --all
	nix profile wipe-history --older-than 30d
	nix store gc
	brew update
	brew outdated
	brew upgrade --cask ${UPDATABLE_CASKS}
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
	brew install --cask ${INSTALLABLE_CASKS} ${UPDATABLE_CASKS}

.PHONY: packages
packages: env-packages dev-packages brew-packages

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
