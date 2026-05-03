function cron-runner --description 'Runs periodic tasks'
  set -l script "$__fish_config_dir/scripts/cron_runner.nu"

  nu $script $argv
end
