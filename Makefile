CONFIG_DIR = ${HOME}/.config
OMZ = ${HOME}/.oh-my-zsh/custom

install: alacritty bpytop tmux neovim zsh


alacritty_bkp: ${CONFIG_DIR}/alacritty/alacritty.yml
	if [[ -e ${CONFIG_DIR}/alacritty/alacritty.yml && ! -h ${CONFIG_DIR}/alacritty/alacritty.yml ]]; then \
		mv ${CONFIG_DIR}/alacritty/alacritty.yml ${CONFIG_DIR}/alacritty/alacritty.yml.old ; \
	fi

alacritty: alacritty_bkp alacritty.yml
	echo "Installing alacritty dotfiles"
	mkdir -p ${CONFIG_DIR}/alacritty
	ln -s ${CURDIR}/alacritty.yml ${CONFIG_DIR}/alacritty/alacritty.yml


bpytop_bkp: ${CONFIG_DIR}/bpytop/bpytop.conf
	if [[ -e ${CONFIG_DIR}/bpytop/bpytop.conf && ! -h ${CONFIG_DIR}/bpytop/bpytop.conf ]]; then \
		mv ${CONFIG_DIR}/bpytop/bpytop.conf ${CONFIG_DIR}/bpytop/bpytop.conf.old ; \
	fi

bpytop: bpytop_bkp bpytop.conf
	echo "Installing bpytop dotfiles"
	mkdir -p ${CONFIG_DIR}/bpytop
	ln -s ${CURDIR}/bpytop.conf ${CONFIG_DIR}/bpytop/bpytop.conf


tmux_bkp: ${HOME}/.tmux.conf
	if [[ -e ${HOME}/.tmux.conf && ! -h ${HOME}/.tmux.conf ]]; then \
		mv ${HOME}/.tmux.conf ${HOME}/.tmux.conf.old ; \
	fi

tmux: tmux_bkp tmux.conf
	echo "Installing tmux dotifiles"
	ln -s ${CURDIR}/tmux.conf ${HOME}/.tmux.conf


top_bkp: ${HOME}/.toprc
	if [[ -e ${HOME}/.toprc && ! -h ${HOME}/.toprc ]]; then \
		mv ${HOME}/.toprc ${HOME}/.toprc.old ; \
	fi

top: top_bkp toprc
	echo "Installing top dotfiles"
	ln -s ${CURDIR}/toprc ${HOME}/.toprc


neovim_bkp: ${CONFIG_DIR}/nvim/init.lua ${CONFIG_DIR}/nvim/lua
	if [[ -e ${CONFIG_DIR}/nvim/init.lua && ! -h ${CONFIG_DIR}/nvim/init.lua ]]; then \
		mv ${CONFIG_DIR}/nvim/init.lua ${CONFIG_DIR}/nvim/init.lua.old ; \
	fi
	if [[ -e ${CONFIG_DIR}/nvim/lua && ! -h ${CONFIG_DIR}/nvim/lua ]]; then \
		mv ${CONFIG_DIR}/nvim/lua ${CONFIG_DIR}/nvim/lua.old ; \
	fi

neovim: neovim_bkp
	echo "Installing neovim dotfiles"
	mkdir -p ${CONFIG_DIR}/nvim
	ln -s ${CURDIR}/neovim/init.lua ${CONFIG_DIR}/nvim/init.lua
	ln -s ${CURDIR}/neovim/lua ${CONFIG_DIR}/nvim/


zsh_bkp: ${HOME}/.zshrc ${OMZ}/themes ${OMZ}/plugins
	if [[ -e ${HOME}/.zshrc && ! -h ${HOME}/.zshrc ]]; then \
		mv ${HOME}/.zshrc ${HOME}/.zshrc.old ; \
	fi
	if [[ -e ${OMZ}/themes && ! -h ${OMZ}/themes ]]; then \
		mv ${OMZ}/themes ${OMZ}/themes.old ; \
	fi
	if [[ -e ${OMZ}/plugins && ! -h ${OMZ}/plugins ]]; then \
		mv ${OMZ}/plugins ${OMZ}/plugins.old ; \
	fi

zsh: zsh_bkp
	echo "Installing ZSH dotfiles"
	ln -s ${CURDIR}/zsh/zshrc ${HOME}/.zshrc
	ln -s ${CURDIR}/zsh/zshrc_local ${HOME}/.zshrc_local
	ln -s ${CURDIR}/zsh/zshrc_local_plugin ${HOME}/.zshrc_local_plugin
	ln -s ${CURDIR}/zsh/themes ${OMZ}
	ln -s ${CURDIR}/zsh/plugins ${OMZ}
