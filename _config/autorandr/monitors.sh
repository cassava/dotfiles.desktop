# monitors.sh
#

source $(dirname "${BASH_SOURCE}")/common.sh

# LCD "34 @ 3440x1440 with a DPI of 110
apply_dell34() {
    monitor_id=${1-$(get_primary_monitor)}

    echo "---"
    load_machine_defaults
    set_machine_monitors $monitor_id $monitor_id
    set_i3_gaps 10 2 2
    set_polybar_mode solo
    set_polybar_options 32 12 9
    set_random_background $monitor_id
    postswitch 110 false
}

# Internal LCD "14 @ 1920x1080 with a DPI of 141
apply_internal14() {
    monitor_id=${1-$(get_primary_monitor)}

    echo "---"
    load_machine_defaults
    set_machine_monitors $monitor_id $monitor_id
    set_i3_gaps 3 0 1
    set_polybar_mode solo
    set_polybar_options 36 12 9
    set_random_background $monitor_id
    postswitch 144 false
}
