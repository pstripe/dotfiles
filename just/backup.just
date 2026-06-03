start-cron:
	#!/usr/bin/env nu
	let session = "backup-tasks"
	let workdir = (pwd)
	let jobs = [
		{
			name: "extract services data"
			workdir: "/home/pavel/services"
			schedule: "12 0 * * *"
			cmd: "just backup::service-data"
		}
		{
			name: "run"
			schedule: "14 0 * * *"
			cmd: "just backup::default"
		}
	]

	^tmux kill-session -t $session | ignore

	let first = $jobs | get 0

	^tmux new-session -d -s $session -n $first.name -c $first.workdir $"cron-runner \"($first.schedule)\" \"($first.cmd)\""

	for job in ($jobs | skip 1) {
		let wd = $job | get --optional workdir | default $workdir
		^tmux new-window -t $session -n $job.name -c $wd $"cron-runner \"($job.schedule)\" \"($job.cmd)\""
	}

	^tmux select-window -t ($session):0

bkp_dir := '/tmp/backup'

default:
	just backup::pack
	just backup::run Dropbox
	just backup::run iCloud
	just backup::cleanup

[no-cd]
service-data:
    just miniflux/backup      {{bkp_dir}}/docker
    just silverbullet/backup  {{bkp_dir}}/docker

pack:
	mkdir -p /tmp/backup/docker

	ouch compress --gitignore ~/services    {{bkp_dir}}/services.tar.zst
	ouch compress --gitignore ~/ledger      {{bkp_dir}}/ledger.tar.zst
	ouch compress --gitignore ~/dotfiles    {{bkp_dir}}/dotfiles.tar.zst
	ouch compress --gitignore ~/projects    {{bkp_dir}}/projects.tar.zst
	ouch compress             ~/ledger.old  {{bkp_dir}}/ledger-old.tar.zst
	ouch compress             ~/Documents   {{bkp_dir}}/documents.tar.zst
	ouch compress             ~/org         {{bkp_dir}}/org.tar.zst

	ouch compress   ~/zigbee2mqtt               {{bkp_dir}}/docker/zigbee2mqtt.tar.zst
	cp              ~/ha_config/backups/*.tar   {{bkp_dir}}/docker/hass.tar

run storage:
	rclone sync {{bkp_dir}}  {{storage}}:backup  --progress --transfers 4 --checksum --delete-during

cleanup:
    rm -r {{bkp_dir}}/*
