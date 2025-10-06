# TODO: add `clean` target

CONFIG_DIR = ${HOME}/.config

EXTRA_CONFIGS  := $(addprefix ${CONFIG_DIR}/,nvim tmux wezterm zellij alacritty)
CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,aerospace bat codebook git ghostty helix nix fish bottom lazygit yazi)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc .zshenv)

ENV_PACKAGES := bat bottom choose eza fd fzf just jq pup ripgrep sd yazi zoxide zstd
ENV_PACKAGES += nix # Manage itself
# shell
ENV_PACKAGES += fish nushell
# editor
ENV_PACKAGES += helix neovim
# markdown
ENV_PACKAGES += glow marksman codebook
# pass
ENV_PACKAGES += pass passExtensions.pass-otp gnupg pinentiry_mac passff-host

# brew deps
# BREW_PKGS := vault
# Updated by Brew
UPDATABLE_CASKS := aerospace alfred docker-desktop font-cascadia-code-nf ghostty pika
# Self updatable casks
INSTALLABLE_CASKS := firefox zoom ${UPDATABLE_CASKS}

# php
DEV_PACKAGES := php phpactor
# git
DEV_PACKAGES += git lazygit delta
# go
DEV_PACKAGES += go gopls delve
# rust
DEV_PACKAGES += cargo rustc rustfmt rust-analyzer
# c/c++
DEV_PACKAGES += cmake
# java
DEV_PACKAGES += jdk17 gradle jdt-language-server
# ai
DEV_PACKAGES += opencode
# various lsp
DEV_PACKAGES += just-lsp vscode-json-language-server yaml-language-server

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
	brew upgrade
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
	brew install --cask ${INSTALLABLE_CASKS}

.PHONY: packages
packages: env-packages dev-packages brew-packages

.PHONY: rust-packages
rust-packages:
	cargo install choose rustic-rs

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
	ln -s ${CURDIR}/home/$(subst .,,$(notdir $@)) $@
