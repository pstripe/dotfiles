# TODO: Fix unexisting dependencies breaks installation process

CONFIG_DIR = ${HOME}/.config
OMZ = ${HOME}/.oh-my-zsh/custom

backup_existing_data = if [[ -e $(1) && ! -h $(1) ]]; then mv $(1) $(1).old ; fi

install: update alacritty bpytop tmux neovim zsh

update:
	git pull origin main


alacritty_bkp: ${CONFIG_DIR}/alacritty/alacritty.yml
	$(call backup_existing_data,${CONFIG_DIR}/alacritty/alacritty.yml)

alacritty: alacritty_bkp alacritty.yml
	echo "Installing alacritty dotfiles"
	mkdir -p ${CONFIG_DIR}/alacritty
	ln -s ${CURDIR}/alacritty.yml ${CONFIG_DIR}/alacritty/alacritty.yml


bpytop_bkp: ${CONFIG_DIR}/bpytop/bpytop.conf
	$(call backup_existing_data,${CONFIG_DIR}/bpytop/bpytop.conf)

bpytop: bpytop_bkp bpytop.conf
	echo "Installing bpytop dotfiles"
	mkdir -p ${CONFIG_DIR}/bpytop
	ln -s ${CURDIR}/bpytop.conf ${CONFIG_DIR}/bpytop/bpytop.conf


tmux_bkp: ${HOME}/.tmux.conf
	$(call backup_existing_data,${HOME}/.tmux)
	$(call backup_existing_data,${HOME}/.tmux.conf)

tmux: tmux_bkp tmux/tmux.conf tmux/plugins
	echo "Installing tmux dotifiles"
	ln -s ${CURDIR}/tmux/tmux.conf ${HOME}/.tmux.conf
	ln -s ${CURDIR}/tmux/plugins ${HOME}/.tmux


top_bkp: ${HOME}/.toprc
	$(call backup_existing_data,${HOME}/.toprc)

top: top_bkp toprc
	echo "Installing top dotfiles"
	ln -s ${CURDIR}/toprc ${HOME}/.toprc


neovim_bkp: ${CONFIG_DIR}/nvim/init.lua ${CONFIG_DIR}/nvim/lua
	$(call backup_existing_data,${CONFIG_DIR}/nvim/init.lua)
	$(call backup_existing_data,${CONFIG_DIR}/nvim/lua)

neovim: neovim_bkp
	echo "Installing neovim dotfiles"
	mkdir -p ${CONFIG_DIR}/nvim
	ln -s ${CURDIR}/neovim/init.lua ${CONFIG_DIR}/nvim/init.lua
	ln -s ${CURDIR}/neovim/lua ${CONFIG_DIR}/nvim/


zsh_bkp: ${HOME}/.zshrc ${OMZ}/themes ${OMZ}/plugins
	$(call backup_existing_data,${HOME}/.zshrc)
	$(call backup_existing_data,${OMZ}/themes)
	$(call backup_existing_data,${OMZ}/plugins)

zsh: zsh_bkp
	echo "Installing ZSH dotfiles"
	ln -s ${CURDIR}/zsh/zshrc ${HOME}/.zshrc
	ln -s ${CURDIR}/zsh/zshrc_local ${HOME}/.zshrc_local
	ln -s ${CURDIR}/zsh/zshrc_local_plugin ${HOME}/.zshrc_local_plugin
	ln -s ${CURDIR}/zsh/themes ${OMZ}
	ln -s ${CURDIR}/zsh/plugins ${OMZ}
