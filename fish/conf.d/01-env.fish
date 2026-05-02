set --global --export LANG en_US.UTF-8
set --global --export XDG_CONFIG_HOME "$HOME/.config"
set --global --export MANPAGER 'nvim +Man!'
set --global --export EDITOR hx

if status is-interactive
    set __fish_ls_command eza
end
