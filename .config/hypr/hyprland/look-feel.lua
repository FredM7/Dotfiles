-- Appearance
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 6,
        border_size = 1,

        col = {
            active_border   = { colors = {"rgba(FF5C00ee)", "rgba(EC0D2Eee)"}, angle = 25 },
            inactive_border = "rgba(1793D1aa)",
        },

        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Dwindle & Master settings
hl.config({ 
  dwindle = { 
    -- pseudotile = true,
    preserve_split = true
  } 
})

hl.config({ 
  master = { 
    new_status = "master"
  }
})

-- Misc
hl.config({
    misc = {
        force_default_wallpaper = 2,
        disable_hyprland_logo   = false,
    }
})