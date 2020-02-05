#!/bin/bash
#
# Configuration is achieved via Xrdb.
#
# Machine parameters:
#
#   machine.hostname
#   machine.monitor-internal
#   machine.monitor-primary
#   machine.monitor-secondary
#   machine.ethernet-primary
#   machine.ethernet-secondary
#   machine.wifi
#
# Polybar parameters:
#
#   polybar.height
#   polybar.font-0
#   polybar.font-1
#   polybar.monitor-primary
#   polybar.monitor-secondary
#
# i3 parameters:
#
#   i3.terminal
#   i3.terminal-alternate
#   i3.browser
#   i3.launcher
#   i3.lock-image
#   i3.monitor-primary
#   i3.monitor-secondary
#   i3.border-width
#   i3.gaps-inner
#   i3.gaps-outer

# Usage: postswitch [DPI]
#
# Before calling this function, you should call the following functions:
#   load_machine_defaults
#   set_machine_monitors
#   set_i3_gaps
#   set_polybar_mode
#   set_polybar_options
postswitch() {
    local dpi=${1:-96}

    set_monitor_dpi $dpi
    set_alacritty_link $dpi
    reset_monitor_background
    reset_keyboard
    reset_i3
}

# Usage: xrdb_query <KEY>
xrdb_query() {
    local key=$1

    xrdb -query | sed -rn "s/^${key}:[ \\t]*(.+)\$/\\1/p"
}

# Usage: load_machine_defaults [PATH TO XDEFAULTS]
load_machine_defaults() {
    local path=${1-~/.local/share/xdefaults/machine/$(hostname)}

    if [[ -f $path ]]; then
        echo "Load $path"
        xrdb -merge $path
    fi

    if [[ -f "$path.sh" ]]; then
        . $path.sh
    fi
}

# Usage: get_monitor_resolution <MONITOR>
get_monitor_resolution() {
    local monitor=$1

    xrandr | grep -F "$monitor" | sed -r 's/^.*\b([0-9]+x[0-9]+)\b.*$/\1/'
}

# Usage: set_machine_monitors [PRIMARY MONITOR] [SECONDARY MONITOR]
set_machine_monitors() {
    local primary=${1-$(xrdb_query machine.monitor-primary)}
    local secondary=${2-$(xrdb_query machine.monitor-secondary)}

    set_i3lock_image "$primary"
    xrdb -merge <<EOF
machine.monitor-primary: $primary
machine.monitor-secondary: $secondary
i3.monitor-primary: $primary
i3.monitor-secondary: $secondary
polybar.monitor-primary: $primary
polybar.monitor-secondary: $secondary
EOF
}

# Usage: set_monitor_dpi [DPI]
set_monitor_dpi() {
    local dpi=${1:-96}

    xrandr --dpi $dpi
    xrdb -merge <<EOF
Xft.dpi: $dpi
Xft.rgba: rgbft*dpi: $dpi
EOF
}

# Usage: set_i3_gaps [INNER] [OUTER] [BORDER WIDTH IN PIXELS]
set_i3_gaps() {
    local inner=${1-0}
    local outer=${2-0}
    local border=${3-0}

    echo "Set i3 gaps: ($inner, $outer)"
    xrdb -merge <<EOF
i3.gaps-inner: $inner
i3.gaps-outer: $outer
i3.border-width: $border
EOF
}

# Usage: set_i3lock_image <MONITOR>
set_i3lock_image() {
    local monitor=$1
    local resolution=$(get_monitor_resolution "$monitor")

    local prefix="$HOME/.local/share/i3lock"
    local image=""
    for file in "$prefix/$resolution.png" "$prefix/default.png"
    do
        if [[ -f "$file" ]]; then
            image="$file"
            break
        fi
    done

    if [[ -f $image ]]; then
        echo "Set i3lock image: $image"
        xrdb -merge <<EOF
i3.lock-image: $image
EOF
    fi
}

# Usage: set_polybar_mode dual|solo
set_polybar_mode() {
    local mode=$1

    local rundir=${XDG_RUNTIME_DIR-/run/user/$(id -u)}/polybar
    if [[ ! -d ${rundir} ]]; then
        mkdir -p $rundir;
    fi
    if [[ $mode == "dual" ]]; then
        echo "Set polybar mode: dual"
        rm -f $rundir/solo
        touch $rundir/dual
    else
        echo "Set polybar mode: solo"
        rm -f $rundir/dual
        touch $rundir/solo
    fi
}

# Usage: set_polybar_options [HEIGHT] [FONT-1 SIZE] [FONT-2 SIZE]
set_polybar_options() {
    local height=${1:-24}
    local font_size_0=${2:-10}
    local font_size_1=${3:-8}

    echo "Set polybar options"
    xrdb -merge <<EOF
polybar.height: $height
polybar.font-0: Noto Sans Nerd Font:size=$font_size_0
polybar.font-1: Unifont:size=$font_size_1
EOF
}

# Usage: set_alacritty_link <DPI>
set_alacritty_link() {
    local dpi=${1:-96}
    local src_filename=alacritty.${dpi}dpi.yml
    local dest_filename=alacritty.yml

    if [[ -d ~/.config/alacritty ]]; then
        cd ~/.config/alacritty
        if [[ -f "$src_filename" ]]; then
            if [[ -e "$dest_filename" ]]; then
                if [[ -h "$dest_filename" ]]; then
                    rm "$dest_filename"
                    ln -s "$src_filename" "$dest_filename"
                else
                    echo "Error: I refuse to overwrite $dest_filename with a symlink."
                fi
            else
                # No file to overwrite here, so ok. If it turns out to be a directory, also ok.
                # This following command will only suceed if there is no file at destination.
                ln -s "$src_filename" "$dest_filename"
            fi
        fi
    fi
}

# Usage: reset_monitor_background
reset_monitor_background() {
    echo "Restore wallpaper"
    nitrogen --restore
}

# Usage: reset_keyboard
reset_keyboard() {
    ~/.local/bin/xsetup-keyboard
}

# Usage: reset_i3
reset_i3() {
    echo "Restart i3"
    i3-msg "restart" >/dev/null
}
