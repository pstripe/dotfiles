# TODO: add `clean` target

CONFIG_DIR = ${HOME}/.config

# Configs
EXTRA_CONFIGS  := $(addprefix ${CONFIG_DIR}/,nvim tmux wezterm zellij alacritty)
CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,aerospace bat codebook git ghostty helix nix fish bottom lazygit yazi)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc .zshenv)

.PHONY: configs
configs: ${CONFIG_TARGETS} ${HOME_TARGETS}

# TODO: remove PHONY somehow and add as packages dependency
.PHONY: nix
nix:
	curl -L https://nixos.org/nix/install | sh

.PHONY: brew
brew:
	# TODO
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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
