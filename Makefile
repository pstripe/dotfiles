# TODO: add `clean` target

CONFIG_DIR = ${HOME}/.config
LOCAL_DIR  = ${HOME}/.local
LOCAL_LIB_DIR  = ${LOCAL_DIR}/lib

# Configs
EXTRA_CONFIGS  := $(addprefix ${CONFIG_DIR}/,nvim tmux)
CONFIG_TARGETS := $(addprefix ${CONFIG_DIR}/,aerospace bat codebook git ghostty helix nix opencode fish bottom lazygit yazi)
CONFIG_TARGETS += $(addprefix ${CONFIG_DIR}/,phpactor)
HOME_TARGETS   := $(addprefix ${HOME}/,.editorconfig .zshrc .zshenv justfile)
LIB_TARGETS    := $(addprefix ${LOCAL_LIB_DIR}/,just)

.PHONY: configs
configs: ${CONFIG_TARGETS} ${HOME_TARGETS} ${LIB_TARGETS}

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

${LOCAL_DIR}:
	mkdir ${LOCAL_DIR}

${CONFIG_TARGETS}: ${CONFIG_DIR}
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${EXTRA_CONFIGS}: ${CONFIG_DIR}
	@echo "Installing config $@"
	ln -s ${CURDIR}/$(notdir $@) $@

${HOME_TARGETS}:
	@echo "Installing config $@"
	ln -s ${CURDIR}/home/$(subst .,,$(notdir $@)) $@

TARGET_MACHINE = ?personal

${LIB_TARGETS}: ${LOCAL_DIR} ${LOCAL_LIB_DIR}
ifeq ($(TARGET_MACHINE), personal)
	@echo "Installing lib $@"
	ln -s ${CURDIR}/$(notdir $@) $@
endif
