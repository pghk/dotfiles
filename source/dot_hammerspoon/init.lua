hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")

spoon.ReloadConfiguration:start()

hs.logger.defaultLogLevel = "info"
hs.window.animationDuration = 0

Grid = require("services.window.grid")
hs.grid.setMargins("8,8") -- keep some space between windows
SetGridGranularity(5) -- set each screen's grid to 5x its aspect ratio

require("hotkeys.binding")
require("hotkeys.modal")

Tiling = require("services.window.tiling")
Tiling.start()

require("hs.ipc")
