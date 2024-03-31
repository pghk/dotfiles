hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

require("hotkeys.binding")
require("services.window.grid")

hs.logger.defaultLogLevel = "info"
hs.window.animationDuration = 0

hs.grid.setMargins("8,8") -- keep some space between windows
SetGridGranularity(5) -- set each screen's grid to 5x its aspect ratio
