if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

set local_share_dir $HOME/.local/share
set nix_share_dir $HOME/.nix-profile/share

set -g XDG_DATA_DIRS $nix_share_dir $local_share_dir $XDG_DATA_DIRS

#set -g __fish_vendor_functionsdirs   $fish_data_dir/vendor_functions.d   $__fish_vendor_functionsdirs
#set -g __fish_vendor_completionsdirs $fish_data_dir/vendor_completions.d $__fish_vendor_completionsdirs
#set -g __fish_vendor_confdirs        $fish_data_dir/vendor_conf.d        $__fish_vendor_confdirs
