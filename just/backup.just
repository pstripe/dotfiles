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
			name: "clear tmps"
			schedule: "58 0 * * *"
			cmd: "just backup::cleanup"
		}
		{
			name: "dropbox backup"
			schedule: "25 0 * * *"
			cmd: "just backup::run dropbox"
		}
		{
			name: "icloud backup"
			schedule: "33 0 * * *"
			cmd: "just backup::run icloud"
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

[no-cd]
service-data:
    just miniflux/backup
    just silverbullet/backup

run storage:
    rustic -P {{storage}} backup
    rustic -P {{storage}} forget --prune

cleanup:
    rm -r /tmp/backup
