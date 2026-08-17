-- ~/.config/hypr/hyprland.lua

-- Load sub-configurations
require("modules.appearance")
require("modules.animations")
require("modules.binds")
require("modules.rules")

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})


-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function () 
   hl.exec_cmd("systemctl --user start polkit-gnome.service")
   hl.exec_cmd("awww-daemon")
   hl.exec_cmd("waybar")
   hl.exec_cmd("hypridle")
   hl.exec_cmd("swaync")
   hl.exec_cmd("~/.local/bin/spotify-notify")
   hl.exec_cmd("python3 ~/.config/quickshell/focustime/focus_daemon.py")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- Cursor Settings
hl.env("XCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

-- Force Native Wayland Toolkits (With Safe XWayland Fallbacks)
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")

-- Java Fix (Prevents blank gray windows in tiling WMs)
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- AMD Hardware Video Decoding (Ryzen 5 5500U iGPU)
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")

-- Modern Qt Theming & Scaling
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")



