#!/bin/bash

set_dpi() {
    local dpi=${1:-96}

    local tmpfile=$(mktemp)
    cat >$tmpfile <<EOF
Xft.dpi: $dpi
Xft.rgba: rgbft*dpi: $dpi
EOF
    xrandr --dpi $dpi
    xrdb -merge $tmpfile
    rm $tmpfile
    i3-msg "restart"
}

set_keyboard() {
    # Set the keyboard to US with my modifications
    setxkbmap -layout us -variant altgr-intl -option terminate:ctrl_alt_bksp,caps:escape,grp:rctrl_toggle,compose:sclk
    [[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
}

set_background() {
    # Load background saved for this monitor
    nitrogen --restore
}

set_polybar_mode() {
    local mode=$1

    local rundir=${XDG_RUNTIME_DIR-/run/user/$(id -u)}/polybar
    if [[ ! -d ${rundir} ]]; then
        mkdir -p $rundir;
    fi
    if [[ $mode == "dual" ]]; then
        rm -f $rundir/solo
        touch $rundir/dual
    else
        rm -f $rundir/dual
        touch $rundir/solo
    fi
}

set_monitors() {
    local primary=$1
    local secondary=$2

    local tmpfile=$(mktemp)
    cat >$tmpfile <<EOF
polybar.monitor-primary: $primary
polybar.monitor-secondary: $secondary
EOF
    xrdb -merge $tmpfile
    rm $tmpfile
}

set_polybar() {
    local height=${1:-24}
    local font_size_0=${2:-10}
    local font_size_1=${3:-8}

    local tmpfile=$(mktemp)
    cat >$tmpfile <<EOF
polybar.height: $height
polybar.font-0: Noto Sans Nerd Font:size=$font_size_0
polybar.font-1: Unifont:size=$font_size_1
EOF
    xrdb -merge $tmpfile
    rm $tmpfile
}

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

postswitch() {
    local dpi=${1:-96}
    set_dpi $dpi
    set_background
    set_alacritty_link $dpi
    set_keyboard
}
