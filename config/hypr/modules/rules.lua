
-------------------------------------------------------------
-------------------------------------------------------------
------------------------LAYER RULES -------------------------
-------------------------------------------------------------
-------------------------------------------------------------


hl.layer_rule({
    name = "notification-animation",
    match = { namespace = "swaync-control-center" },
    animation = "fade"
})

hl.layer_rule({
    name = "wlogout-blur",
    match = { namespace = "logout_dialog" },
    blur = true,
})

hl.layer_rule({
    name = "rofi",
    match = { namespace = "rofi" },
    animation = "slide"
})


-------------------------------------------------------------
-------------------------------------------------------------
-----------------------WINDOW RULES -------------------------
-------------------------------------------------------------
-------------------------------------------------------------


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

----------------------
-- Auto-float rules --
----------------------

hl.window_rule({
    name              = "mpv-floating-16-9",
    match             = { class = "org.gnome.Showtime|mpv" },
    float             = true,
    size              = "1280 720",
    keep_aspect_ratio = false, 
})

hl.window_rule({
    name              = "imv-floating-16-9",
    match             = { class = "imv|org.gnome.Loupe" },
    float             = true,
    keep_aspect_ratio = false,
})

hl.window_rule({
    name              = "recorder",
    match             = { class = "org.gnome.SoundRecorder" },
    size              = "640  480",
    float             = true,
    keep_aspect_ratio = true,
})

hl.window_rule({
    name              = "clocks",
    match             = { class = "org.gnome.clocks" },
    size              = "733  619",
    float             = true,
    keep_aspect_ratio = true,
})

hl.window_rule({
    name              = "hyprland",
    match             = { class = "hyprland-share-picker" },
    size              = "696 270",
    float             = true,
    keep_aspect_ratio = false,
})

hl.window_rule({
    name              = "spotify",
    match             = { class = "Spotify" },
    size              = "1370 834",
    float             = true,
    keep_aspect_ratio = false,
})

hl.window_rule({
    name              = "calc",
    match             = { class = "org.gnome.Calculator" },
    size              = "410 616",
    float             = true,
    keep_aspect_ratio = false,
    opacity           = "0.90", 
})

-------------------
-- Opacity Rules --
-------------------

hl.window_rule({
    name  = "thunar-opacity",
    match = { class = "thunar|Thunar" },
    opacity = "0.90" 
})

hl.window_rule({
    name  = "nautilus-opacity",
    match = { class = "org.gnome.Nautilus" },
    opacity = "0.90" 
})

hl.window_rule({
    name  = "spotify-blur",
    match = { class = "Spotify" },
    opacity = "0.80" 
})

hl.window_rule({
    name  = "vesktop-blur",
    match = { class = "vesktop" },
    opacity = "1" 
})



