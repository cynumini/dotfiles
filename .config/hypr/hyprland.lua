hl.monitor({
    output = "",
    mode = "highrr",
})

local wallpaper = os.getenv("HOME") .. "/pictures/wallpaper.png"

-- hl.notification.create({text = "Test message", timeout = 10000})

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("gentoo-pipewire-launcher restart")
    hl.exec_cmd("swaybg -i " .. wallpaper)
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("playerctld")
    hl.exec_cmd('swayidle -w timeout 600 "loginctl suspend" before-sleep "swaylock -f -i ' .. wallpaper .. '"')
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.bind("SUPER + t", hl.dsp.exec_cmd("tts.py"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("tts-jp.py"))
hl.bind("SUPER + SHIFT + equal", hl.dsp.exec_cmd("zoomer"))
hl.bind("SUPER + z", hl.dsp.exec_cmd("anki-screenshot.sh"))
hl.bind("SUPER + x", hl.dsp.exec_cmd("record-audio.sh"))
hl.bind("Print", hl.dsp.exec_cmd('grim - | wl-copy'))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("screenshot.sh"))
hl.bind("SUPER + SHIFT + s", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind("SUPER + q", hl.dsp.exec_cmd("foot"))
hl.bind("SUPER + e", hl.dsp.exec_cmd("dolphin"))
hl.bind("SUPER + r", hl.dsp.exec_cmd("rofi -show drun -show-icons"))
hl.bind("SUPER + SHIFT + r", hl.dsp.exec_cmd("rofi -show run"))

hl.bind("SUPER + minus", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%- -l 1"))
hl.bind("SUPER + equal", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+ -l 1"))

hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SUPER + p", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("playerctl next"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + SHIFT + c", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + m", hl.dsp.exit())
hl.bind("SUPER + f", hl.dsp.group.toggle())
hl.bind("SUPER + SHIFT + f", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + v", hl.dsp.window.float())

hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))

hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "down", group_aware = true }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "up", group_aware = true }))
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "left", group_aware = true }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "right", group_aware = true }))

hl.bind("SUPER + TAB", hl.dsp.group.next())
hl.bind("SUPER + SHIFT + TAB", hl.dsp.group.prev())
hl.bind("SUPER + bracketright", hl.dsp.group.move_window({ forward = true }))
hl.bind("SUPER + bracketleft", hl.dsp.group.move_window({ forward = false }))
hl.bind("SUPER + G", hl.dsp.group.lock())

for i = 1, 9 do
    hl.bind("ALT + " .. i, hl.dsp.group.active({ index = i }), { non_consuming = true })
end

for i = 1, 6 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
    },
    input = {
        accel_profile = "flat",
    },
    decoration = {
        blur = {
            enabled = false
        }
    },
    group = {
        col = {
            border_active = "#FFFFFFFF"
        },
        groupbar = {
            font_family = "Iosevka",
            font_size = 16,
            col = {
                active          = "#FFFFFFFF",
                inactive        = "#000000FF",
                locked_active   = "#FFCCCCFF",
                locked_inactive = "#330000FF",
            },
            text_color = "#000000FF",
            text_color_inactive = "#FFFFFFFF",
            gradients = true,
            gaps_in = 0,
            gaps_out = 0,
        }
    },
    animations = {
        enabled = false,
    },
})
