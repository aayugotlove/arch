#!/bin/bash

iDIR="$HOME/.config/swaync/icons"
notification_timeout=1000
step=5

# Get current volume
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'
}

# Check if muted
is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

# Pick icon
get_icon() {
    if is_muted; then
        icon="$iDIR/volume-slash.svg"
        current=0
        return
    fi

    current=$(get_volume)

    if [ "$current" -eq 0 ]; then
        icon="$iDIR/volume-slash.svg"
    elif [ "$current" -le 5 ]; then
        icon="$iDIR/volume-slash.svg"
    elif [ "$current" -le 15 ]; then
        icon="$iDIR/volume-off.svg"
    elif [ "$current" -le 55 ]; then
        icon="$iDIR/volume-low.svg"
    else
        icon="$iDIR/volume.svg"
    fi
}

# Notify
notify_user() {
    if is_muted; then
        text="Muted"
    else
        text="Volume: ${current}%"
    fi

    notify-send \
        -e \
        -h string:x-canonical-private-synchronous:volume_notif \
        -h int:value:"$current" \
        -u low \
        -i "$icon" \
        -t "$notification_timeout" \
        "Volume" \
        "$text"
}
# Increase
volume_up() {
    wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "${step}%+"
    get_icon
    notify_user
}

# Decrease
volume_down() {
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "${step}%-"
    get_icon
    notify_user
}

# Toggle mute
toggle_mute() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    get_icon
    notify_user
}

case "$1" in
    --inc)
        volume_up
        ;;
    --dec)
        volume_down
        ;;
    --mute)
        toggle_mute
        ;;
    *)
        get_icon
        notify_user
        ;;
esac
