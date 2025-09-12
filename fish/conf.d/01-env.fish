set --universal --export LANG en_US.UTF-8
set --universal --export XDG_CONFIG_HOME "$HOME/.config"
set --universal --export MANPAGER 'nvim +Man!'
set --universal --export EDITOR hx

if status is-interactive
    set __fish_ls_command eza
end
