-- ~/.config/hypr/appearance.lua
local colors = require("colors")

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 9,
        border_size = 2,
        col = {
            active_border   = colors.primary,
            inactive_border = none,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding      = 12,
        rounding_power = 12,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = false,
            range        = 10,
            render_power = 1,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled   = true,
            size      = 5,
            passes    = 3,
            xray      = false,
            vibrancy = 0.1696,
            ignore_opacity = true,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true, 
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true 
    },
})
