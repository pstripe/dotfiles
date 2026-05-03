set --global --export LANG en_US.UTF-8
set --global --export XDG_CONFIG_HOME "$HOME/.config"
set --global --export EDITOR hx

# man
set --global --export MANPAGER "fish -c 'col -bx | bat -plman'"
# set --global --export MANROFFOPT '-c'

if status is-interactive
    set __fish_ls_command eza
end
