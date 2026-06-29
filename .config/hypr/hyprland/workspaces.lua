local module = {}

function module.load(mainMod)
  -- Workspaces
  for i = 1, 9 do
      local ws = tostring(i)
      hl.bind(mainMod .. " + " .. ws, hl.dsp.focus({ workspace = i }))
      hl.bind(mainMod .. " + SHIFT + " .. ws, hl.dsp.window.move({ workspace = i }))
      hl.bind(mainMod .. " + CTRL + " .. ws, hl.dsp.window.move({ workspace = i, silent = true }))
  end
  -- 10th workspace (0)
  hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

  -- Special workspace
  hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
  hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

  -- Mouse wheel
  hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
  hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))

  -- Workspace rules
  hl.workspace_rule({ workspace = 1,  monitor = "HDMI-A-1", persistent = true,  default = true })
  hl.workspace_rule({ workspace = 2,  monitor = "HDMI-A-1", persistent = true })
  hl.workspace_rule({ workspace = 3,  monitor = "HDMI-A-1", persistent = true })
  hl.workspace_rule({ workspace = 4,  monitor = "HDMI-A-1", persistent = true })
  hl.workspace_rule({ workspace = 5,  monitor = "HDMI-A-1", persistent = true })
  hl.workspace_rule({ workspace = 6,  monitor = "HDMI-A-2", persistent = true,  default = true })
  hl.workspace_rule({ workspace = 7,  monitor = "HDMI-A-2", persistent = true })
  hl.workspace_rule({ workspace = 8,  monitor = "HDMI-A-2", persistent = true })
  hl.workspace_rule({ workspace = 9,  monitor = "HDMI-A-2", persistent = true })
  hl.workspace_rule({ workspace = 10, monitor = "HDMI-A-2", persistent = true })
end

return module