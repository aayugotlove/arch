#!/bin/bash

iDIR="$HOME/.config/swaync/icons"
notification_timeout=1000
step=5

# Get brightness
get_backlight() {
    brightnessctl -m | cut -d, -f4 | sed 's/%//'
}

# Get icon
get_icon() {
    current=$(get_backlight)

    if [ "$current" -le "20" ]; then
        icon="$iDIR/brightness-60.svg"
    elif [ "$current" -le "40" ]; then
        icon="$iDIR/brightness-60.svg"
    elif [ "$current" -le "60" ]; then
        icon="$iDIR/brightness-90.svg"
    elif [ "$current" -le "80" ]; then
        icon="$iDIR/brightness-90.svg"
    else
        icon="$iDIR/brightness-90.svg"
    fi
}

# Notify
notify_user() {
    notify-send \
        -e \
        -h string:x-canonical-private-synchronous:brightness_notif \
        -h int:value:"$current" \
        -u low \
        -i "$icon" \
        -t "$notification_timeout" \
        "Screen" \
        "Brightness: ${current}%"
}

# Change brightness
change_backlight() {
    local current_brightness
    current_brightness=$(get_backlight)

    if [[ "$1" == "+${step}%" ]]; then
        new_brightness=$((current_brightness + step))
    elif [[ "$1" == "${step}%-" ]]; then
        new_brightness=$((current_brightness - step))
    else
        exit 1
    fi

    # Clamp values
    if (( new_brightness < 5 )); then
        new_brightness=5
    elif (( new_brightness > 100 )); then
        new_brightness=100
    fi

    brightnessctl set "${new_brightness}%"

    current=$new_brightness
    get_icon
    notify_user
}

# Execute
case "$1" in
    "--get")
        get_backlight
        ;;
    "--inc")
        change_backlight "+${step}%"
        ;;
    "--dec")
        change_backlight "${step}%-"
        ;;
    *)
        get_backlight
        ;;
esac
