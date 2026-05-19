#!/usr/bin/env nu
# usage:
#   cron_runner.nu "0 3 * * *" "./backup.sh"
#   cron_runner.nu "30 2 * * 0" "nu ./weekly-cleanup.nu"

def parse_field [field: string, min: int, max: int] {
    # поддержка: *, число, список через ,, интервалы X-Y
    if $field == "*" {
        return (seq $min $max)
    }

    let parts = ($field | split row ",")
    mut out: list<int> = []
    for p in $parts {
        let p = ($p | str trim)
        if ($p | str contains "-") {
            let r = ($p | split row "-")
            let a = ($r.0 | into int)
            let b = ($r.1 | into int)

            $out = $out | append (seq $a $b)
        } else {
            $out = $out | append ($p | into int)
        }
    }

    $out | sort | uniq
}

def cron_parse [expr: string] {
    let parts = ($expr | split row " " | where {|x| $x != ""})
    if ($parts | length) != 5 {
        error make { msg: $"invalid cron expr: ($expr)" }
    }

    {
        mins:  (parse_field $parts.0 0 59)
        hours: (parse_field $parts.1 0 23)
        dom:   (parse_field $parts.2 1 31)
        mon:   (parse_field $parts.3 1 12)
        dow:   (parse_field $parts.4 0 6)  # 0=Sunday
    }
}

def cron_match [spec, t: record] {
    # t: record { min hour dom mon dow }
    ($t.min in $spec.mins) and ($t.hour in $spec.hours) and ($t.dom in $spec.dom) and ($t.mon in $spec.mon) and ($t.dow in $spec.dow)
}

def now_fields [] {
    let s = date now | format date "%M %H %d %m %w"
    let p = $s | split row " "
    {
        min:  ($p.0 | into int)
        hour: ($p.1 | into int)
        dom:  ($p.2 | into int)
        mon:  ($p.3 | into int)
        dow:  ($p.4 | into int)
    }
}

def main [
    cron: string,      # "0 3 * * *"
    cmd: string        # "nu ./backup.nu"
] {
    let spec = (cron_parse $cron)
    print $"[runner] cron: ($cron), cmd: ($cmd)"

    mut last_run_ts = 0

    loop {
        let t = (now_fields)
        let now = date now
        let ts = $now | format date "%s" | into int

        # избегаем повторного запуска в ту же минуту при частом цикле
        if (cron_match $spec $t) and $ts - $last_run_ts > 55 {
            print $"[runner] run at ($now) -> ($cmd)"

            let r = do { ^bash -c $"($cmd)" } | complete | inspect 
          
            print $"[runner] exit: ($r.exit_code) at (date now)"
            $last_run_ts = $ts
        }

        sleep 10sec
    }
}
