#!/usr/bin/env bash

thunar -q >/dev/null 2>&1 || true
nautilus -q >/dev/null 2>&1 || true

if pgrep -x spotify >/dev/null; then
    nohup sh -c '
        spicetify apply -n
        pkill spotify
        spotify
    ' >/dev/null 2>&1 &
fi
