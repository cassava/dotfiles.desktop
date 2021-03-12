#!/usr/bin/env bash

runtime_dir="${XDG_RUNTIME_DIR-/run/user/$(id -u)}/polybar"
config_dir="${XDG_CONFIG_HOME-${HOME}/.config}/polybar"
default_config="${config_dir}/config"
if [[ -f "${config_dir}/$(hostname).conf" ]]; then
    host_config="${config_dir}/$(hostname).conf"
fi

# Check whether we should launch multiple polybars
is_mode_dual() {
    local mode_file="${runtime_dir}/mode"
    if [[ -f "${mode_file}" ]]; then
        test "$(cat "${mode_file}")" == "dual"
    else
        false
    fi
}

# Terminate already running bar instances and wait until they have all been
# shutdown.
killall_polybars() {
    echo "Kill all polybars..."
    killall -q polybar
    while pgrep -u $UID -x polybar >/dev/null; do sleep .5; done
}

run_polybar() {
    local bar=$1
    local config="${runtime_dir}/config"

    echo "Generating config: ${config}"
    cat "${default_config}" "${host_config}" > "${config}"

    echo "Starting polybar $bar"
    polybar -c "${config}" $bar &
}

mkdir -p "${runtime_dir}"
killall_polybars
if is_mode_dual; then
    run_polybar dual-primary
    run_polybar dual-secondary
else
    run_polybar solo
fi
