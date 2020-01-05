#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep .5; done

# Launch bar1 and bar2
if [[ -f ${XDG_RUNTIME_DIR-/run/user/$(id -u)}/polybar/dual ]]; then
    polybar dual-primary &
    polybar dual-secondary &
else
    polybar solo &
fi

echo "Polybar launched"
