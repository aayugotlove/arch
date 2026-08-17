#!/bin/bash

pkill waybar 
pkill swaync


waybar -c ~/.config/waybar/config-game.jsonc -s ~/.config/waybar/style-game.css &
swaync &
