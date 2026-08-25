hl.env("XCURSOR_SIZE", "24")
hl.env("QT_CURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Capitaine-Dark")
hl.env("HYPRCURSOR_THEME", "Capitaine-Dark")
hl.env("GSK_RENDERER", "ngl")
hl.env("AMD_VULKAN_ICD", "RADV")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- below 2 was added trying to get jellyfin to work, but it didn't help so far
-- hl.env("QT_QPA_PLATFORM", "xcb")
-- hl.env("LC_NUMERIC", "C")

-- this was added for quickshell to force wayland
hl.env("QT_QPA_PLATFORM", "wayland")