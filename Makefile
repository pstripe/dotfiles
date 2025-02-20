# TODO: add `clean` target

CONFIG_DIR = ${HOME}/.config

EXTRA_CONFIGS  := $(addprefix ${CONFIG_DIR}/,helix tmux zellij alacritty)
CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,aerospace bat git ghostty nvim nix fish bottom wezterm lazygit yazi)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc)

ENV_PACKAGES := bat bottom broot eza fd fzf jq pup ripgrep sd yazi zstd
ENV_PACKAGES += nix # Manage itself
# shell
ENV_PACKAGES += fish nushell
# editor
ENV_PACKAGES += helix neovim
# markdown
ENV_PACKAGES += glow marksman

# brew deps
CASK_PACKAGES := aerospace alfred font-cascadia-code-nf ghostty monitorcontrol pika wezterm docker

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
	# INFO: by some reason `brew upgrade` doesn't work for casks
	brew install --cask ${CASK_PACKAGES}
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
	brew install --cask ${CASK_PACKAGES}

.PHONY: packages
packages: env-packages dev-packages

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
