local terminal    = "ghostty"
local fileManager = "nemo"
local menu        = "quickshell -c launcher ipc call launcher toggle" --"rofi -show drun"
local mainMod = "SUPER"

require("hyprland/monitors")
require("hyprland/autostart")
require("hyprland/env-vars")
require("hyprland/input")
require("hyprland/workspaces").load(mainMod)
require("hyprland/window-rules")
require("hyprland/binds").load({
    mainMod = mainMod,
    terminal = terminal,
    fileManager = fileManager,
    menu = menu,
})
require("hyprland/look-feel")
require("hyprland/animations")
require("hyprland/gestures")

----------------
---- PLUGIN ----
----------------

-- Hyprexpo
-- hl.plugin("hyprexpo", {
--     columns         = 3,
--     gap_size        = 5,
--     bg_col          = "rgb(111111)",
--     workspace_method = "center current",
-- })