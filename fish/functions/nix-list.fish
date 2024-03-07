function nix-list --description 'Prints list of installed Nix packages'
  set -l script "$__fish_config_dir/scripts/nix-list.nu"

  nu $script
end
