hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

local gridActions = require("grid")
local terminal = require("terminal")
local window = require("windows")

hs.logger.defaultLogLevel = "info"
hs.window.animationDuration = 0

-- [[ MODIFIER KEYS ]]
local meh = { "shift", "ctrl", "alt" }
local hyper = { "shift", "ctrl", "alt", "cmd" }

hs.grid.setMargins("8,8") -- keep some space between windows
gridActions.setAllGrids(4) -- set each screen's grid to 4x its aspect ratio
hs.hotkey.bind(meh, "[", function() gridActions.setAllGrids(-1, true) end)
hs.hotkey.bind(meh, "]", function() gridActions.setAllGrids(1, true) end)

local singleUseActions = {
  { meh, "space", terminal.toggle },

  -- Top row: tiled window positioning, floating window quick sizing
  { meh, "6", window.pane.rotate },
  { meh, "7", window.pane.swap },
  { meh, "8", window.pane.super },
  { meh, "9", hs.grid.maximizeWindow },

  { hyper, "6", gridActions.rotate },
  { hyper, "7", gridActions.scaleDown },
  { hyper, "8", gridActions.scaleUp },
  { hyper, "9", gridActions.center },

  -- Home row: tile focus, high level window mgmt
  { meh, "h", window.pane.focusWest },
  { meh, "j", window.pane.focusSouth },
  { meh, "k", window.pane.focusNorth },
  { meh, "l", window.pane.focusEast },

  { hyper, "h", window.space.focusWest },
  { hyper, "j", gridActions.moveToNextScreen },
  { hyper, "k", window.pane.float },
  { hyper, "l", window.space.focusEast },

  -- Bottom row: screen-level window managment
  { meh, "n", window.layout.rotate },
  { meh, "m", window.layout.flip },
  { meh, ",", window.layout.balance },
  { meh, ".", window.layout.reset },

  -- note: hyper + [,.] are reserved by macOS
  { hyper, "n", window.space.toggleLayout },
  { hyper, "m", window.presets },
}

local repeatableActions = {
  -- Upper row: floating window positioning and fine-grained sizing
  { meh, "y", hs.grid.pushWindowLeft },
  { meh, "u", hs.grid.pushWindowDown },
  { meh, "i", hs.grid.pushWindowUp },
  { meh, "o", hs.grid.pushWindowRight },

  { hyper, "y", hs.grid.resizeWindowThinner },
  { hyper, "u", hs.grid.resizeWindowTaller },
  { hyper, "i", hs.grid.resizeWindowShorter },
  { hyper, "o", hs.grid.resizeWindowWider },
}

for _, v in ipairs(singleUseActions) do
  hs.hotkey.bind(v[1], v[2], function() v[3]() end)
end

for _, v in ipairs(repeatableActions) do
  hs.hotkey.bind(v[1], v[2], function() v[3]() end, nil, function() v[3]() end)
end
