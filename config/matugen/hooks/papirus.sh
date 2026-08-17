#!/usr/bin/env bash

set -euo pipefail

PRIMARY_HEX="${1:-}"

if [[ -z "$PRIMARY_HEX" ]]; then
    echo "Usage: $0 '#RRGGBB'"
    exit 1
fi

PRIMARY_HEX="${PRIMARY_HEX#\#}"

# ---------- HEX -> RGB ----------

R=$((16#${PRIMARY_HEX:0:2}))
G=$((16#${PRIMARY_HEX:2:2}))
B=$((16#${PRIMARY_HEX:4:2}))

R1=$((R * 1000 / 255))
G1=$((G * 1000 / 255))
B1=$((B * 1000 / 255))

MAX=$R1
((G1 > MAX)) && MAX=$G1
((B1 > MAX)) && MAX=$B1

MIN=$R1
((G1 < MIN)) && MIN=$G1
((B1 < MIN)) && MIN=$B1

DELTA=$((MAX - MIN))
L=$(((MAX + MIN) / 2))

if ((DELTA == 0)); then
    H=0
    S=0
else
    if ((L < 500)); then
        S=$((DELTA * 1000 / (MAX + MIN)))
    else
        S=$((DELTA * 1000 / (2000 - MAX - MIN)))
    fi

    if ((MAX == R1)); then
        H=$((60 * (G1 - B1) * 1000 / DELTA))
        H=$((H / 1000))
        ((H < 0)) && H=$((H + 360))
    elif ((MAX == G1)); then
        H=$((60 * (B1 - R1) * 1000 / DELTA / 1000 + 120))
    else
        H=$((60 * (R1 - G1) * 1000 / DELTA / 1000 + 240))
    fi
fi

pick_color() {

    local h=$1
    local s=$2
    local l=$3

    if ((s < 80)); then
        if ((l > 850)); then
            echo white
        elif ((l > 650)); then
            echo grey
        elif ((l > 350)); then
            echo bluegrey
        else
            echo black
        fi
        return
    fi

    if   ((h < 15));  then echo red
    elif ((h < 30));  then echo deeporange
    elif ((h < 50));  then echo orange
    elif ((h < 70));  then echo yellow
    elif ((h < 150)); then echo green
    elif ((h < 185)); then echo teal
    elif ((h < 210)); then echo cyan
    elif ((h < 230)); then
        if ((s < 350)); then
            echo bluegrey
        else
            echo blue
        fi
    elif ((h < 260)); then echo indigo
    elif ((h < 290)); then echo violet
    elif ((h < 330)); then echo magenta
    elif ((h < 350)); then echo pink
    else
        echo red
    fi
}

COLOR=$(pick_color "$H" "$S" "$L")

CACHE="$HOME/.cache/papirus-folder-color"

LAST=""
[[ -f "$CACHE" ]] && LAST=$(<"$CACHE")

if [[ "$LAST" != "$COLOR" ]]; then
    sudo -n papirus-folders -C "$COLOR" --theme Papirus-Dark
    echo "$COLOR" > "$CACHE"
fi

gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark

echo "Papirus: $COLOR"


