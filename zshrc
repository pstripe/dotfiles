if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]
then
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if command -v fish &> /dev/null
then
	exec fish -l
fi
