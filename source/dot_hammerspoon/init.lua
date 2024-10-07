hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")

require("hotkeys.binding")
require("services.window.grid")
spoon.ReloadConfiguration:start()

hs.logger.defaultLogLevel = "info"
hs.window.animationDuration = 0

hs.grid.setMargins("8,8") -- keep some space between windows
SetGridGranularity(5) -- set each screen's grid to 5x its aspect ratio
