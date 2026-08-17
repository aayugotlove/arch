#!/usr/bin/env bash

# 1. Create a log file so we aren't blind!
LOG="/tmp/spicetify-reload.log"
echo "--- Matugen Hook Triggered at $(date) ---" > "$LOG"

# 2. Fix the PATH so Matugen knows where the Spicetify command is
export PATH=$PATH:$HOME/.spicetify:$HOME/.local/bin
echo "PATH set to: $PATH" >> "$LOG"

# 3. Use EXACT matching (-x) to ensure we only trigger if the actual GUI is open.
# This stops random popups from 'spotifyd' or 'spotify-launcher' running in the bg.
if ! pgrep -x "spotify" > /dev/null && ! pgrep -x "spotify-client" > /dev/null && ! pgrep -f "com.spotify.Client" > /dev/null; then
    echo "Spotify GUI is closed. Doing nothing." >> "$LOG"
    exit 0
fi

echo "Spotify is running! Starting watch -s..." >> "$LOG"

# 4. Run watch WITH the -s flag (required for the UI refresh)
spicetify watch -s >> "$LOG" 2>&1 &
WATCH_PID=$!

# 5. Wait 3 seconds for CPU load to settle and WebSocket to connect
sleep 3

# 6. Touch the file to trigger the watcher
touch "$HOME/.config/spicetify/Themes/text/color.ini"
echo "Touched color.ini" >> "$LOG"

# 7. Wait 2 seconds for injection to finish
sleep 2

# 8. Kill the watcher cleanly
kill $WATCH_PID 2>/dev/null
echo "Hot-reload successful!" >> "$LOG"
