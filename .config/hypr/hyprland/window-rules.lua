-- Window rules
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({ name = "float-ghostty", match = { class = "com.mitchellh.ghostty" }, float = true })
hl.window_rule({ name = "float-speedcrunch", match = { class = "Speedcrunch" }, float = true })
hl.window_rule({ name = "float-pavucontrol", match = { class = "org.pulseaudio.pavucontrol" }, float = true, size = {800, 1000} })
hl.window_rule({ name = "float-galculator", match = { class = "galculator" }, float = true, size = {346, 342} })
hl.window_rule({ name = "float-nemo", match = { class = "nemo" }, float = true, size = {800, 600} })
hl.window_rule({ name = "float-1password", match = { class = "1password" }, float = true, size = {800, 600} })
hl.window_rule({ name = "float-localsend", match = { class = "localsend" }, float = true, size = {700, 500} })
hl.window_rule({ name = "float-diskutility", match = { class = "org.gnome.DiskUtility" }, float = true })
hl.window_rule({ name = "float-blueman-manager", match = { class = "blueman-manager" }, float = true, size = {800, 600} })
-- initial title "2 Reminders"
hl.window_rule({ name = "float-mozilla-reminders",   match = { class = "org.mozilla.Thunderbird", initial_title = "Calendar Reminders" }, float = true })
-- title "Edit Event:"
hl.window_rule({ name = "float-items",        match = { class = "org.mozilla.Thunderbird", initial_title = "Edit Item" }, float = true })
hl.window_rule({ name = "float-events",        match = { class = "org.mozilla.Thunderbird", title = "^Edit Event:" }, float = true })

-- More window rules (Thunderbird, portals, etc.)
hl.window_rule({
    name  = "float-thunderbird-write",
    match = { class = "org.mozilla.Thunderbird", initial_title = "^(.*Write:.*)$" },
    float = true,
    size  = {800, 600},
    center = true,
})

hl.window_rule({
    name  = "float-open-files-dialog",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true,
    size  = {800, 600},
})