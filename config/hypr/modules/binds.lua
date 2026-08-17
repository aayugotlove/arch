-- ~/.config/hypr/binds.lua[cite: 2]

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            disable_while_typing = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = 0.5,
})


-------------------
---- VARIABLES ----
-------------------

local terminal    = "foot"
local fileManager = "thunar"
local menu        = "rofi -show drun || pkill rofi"
local mainMod     = "SUPER"

---------------------
---- KEYBINDINGS ----
---------------------
-- Apps & General
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/waybar/redo.sh"))
hl.bind("ALT + R", hl.dsp.exec_cmd("~/.config/waybar/redo-game.sh"))
hl.bind("ALT + S", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd([[ pkill rofi || ~/.local/bin/aayufy]]))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock -c ~/.config/hypr/hyprlock/hyprlock.conf"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.local/bin/toggle-grayscale"))
hl.bind("ALT + F4", hl.dsp.exec_cmd("~/.config/wlogout/launch.sh"))

hl.bind("SUPER + F", hl.dsp.exec_cmd([[pkill quickshell || quickshell -p ~/.config/quickshell/focustime/main.qml]]))

-----------------
-- Screenshots --
-----------------

hl.bind("Print", hl.dsp.exec_cmd([[TARGET="$HOME/Pictures/$(date +%Y%m%d_%Hh%Mm%Ss)_grim.png"; grim -g "$(slurp)" "$TARGET" && wl-copy < "$TARGET"]]))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[TARGET="$HOME/Pictures/$(date +%Y%m%d_%Hh%Mm%Ss)_grim.png"; grim "$TARGET" && wl-copy < "$TARGET"]]))

----------------------
-- Focus & Movement --
----------------------

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT  + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT  + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT  + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT  + down", hl.dsp.window.move({ direction = "down" }))

----------------
-- Workspaces --
----------------

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-----------------
-- Mouse Binds --
-----------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

------------------------
-- Media & Brightness --
------------------------

hl.bind("XF86WebCam", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh --inc"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh --dec"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh --mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh --inc"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness.sh --dec"), { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

----------------------
-- Minimized toggle --
----------------------

hl.bind("SUPER + X", function ()
    if hl.get_workspace("special:minimized") then
        hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:minimized" }))
        hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
    else
        hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = hl.get_active_window() }))
        hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
    end
end)

-------------------
-- Layout Toggle --
-------------------

hl.bind("SUPER + tab", function ()
    local layouts     = { "dwindle", "scrolling" }
    local workspace   = hl.get_active_workspace()
    if hl.get_active_special_workspace() then
        workspace = hl.get_active_special_workspace()
    end

    local next_layout = "dwindle"
    if not workspace then return end

    for i = 1, #layouts do
        if layouts[i] == workspace.tiled_layout then
            local next_layout_idx = (i % #layouts) + 1
            next_layout = layouts[next_layout_idx]
            break
        end
    end

    if workspace.special then
        hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
    else
        hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
    end
end)

----------------------
-- Game Mode Toggle --
----------------------

hl.bind("SUPER + XF86AudioMute", function ()
    local game_mode = (hl.get_config("animations.enabled") == false)

    if game_mode then
        -- Restore Hyprland config
        hl.exec_cmd("hyprctl reload")
        -- Restart Waybar with normal config
        hl.exec_cmd("pkill waybar && waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &")
        return
    end

    hl.config({
        general = { gaps_in = 1, gaps_out = 0, border_size = 0 },
        animations = { enabled = false },
        decoration = { shadow = { enabled = false }, blur = { enabled = false }, rounding = 0 }
    })

    -- Restart Waybar with game-mode config
    hl.exec_cmd("pkill waybar && waybar -c ~/.config/waybar/config-game.jsonc -s ~/.config/waybar/style-game.css &")
end)



