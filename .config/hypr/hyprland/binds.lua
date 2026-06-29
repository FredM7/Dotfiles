local binds = {}

function binds.load(config) --(mainMod, terminal, fileManager, menu)
  local mainMod      = config.mainMod
  local terminal     = config.terminal
  local fileManager  = config.fileManager
  local menu         = config.menu

  hl.bind(mainMod .. " + Q",         hl.dsp.exec_cmd(terminal))
  hl.bind(mainMod .. " + C",         hl.dsp.window.close())
  hl.bind(mainMod .. " + DELETE",    hl.dsp.exit())
  hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))
  hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
  hl.bind(mainMod .. " + T",         hl.dsp.window.swap({ next = true }))
  hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized" }))
  hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
  hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd(menu))
  hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
  hl.bind(mainMod .. " + R",         hl.dsp.layout("togglesplit"))
  hl.bind("Print",                   hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
  hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("kooha"))
  hl.bind(mainMod .. " + Z",         hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
  hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("hyprlock"))

  -- Arrow keys focus
  hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
  hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
  hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
  hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

  -- 
  hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
  hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = 10, silent = true }))

  -- Mouse bindings
  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

  -- Media keys
  hl.bind("mouse:276", hl.dsp.exec_cmd("pactl -- set-sink-volume 0 +5%"))
  hl.bind("mouse:275", hl.dsp.exec_cmd("pactl -- set-sink-volume 0 -5%"))
  -- hl.bind("", "XF86AudioMute", "exec", "amixer sset 'Master' toggle")
  -- hl.bind("", "XF86AudioRaiseVolume", "exec", "pactl -- set-sink-volume 0 +5%")
  -- hl.bind("", "XF86AudioLowerVolume", "exec", "pactl -- set-sink-volume 0 -5%")
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("amixer sset 'Master' toggle"))
  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl -- set-sink-volume 0 +5%"))
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl -- set-sink-volume 0 -5%"))

  -- Hyprexpo
  -- bind = $mainMod, TAB, hyprexpo:expo, toggle
  -- hl.bind(mainMod .. " + TAB", hl.dsp.layout("hyprexpo:expo", { action = "toggle" }))
  -- hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprexpo:expo toggle"))
end

return binds