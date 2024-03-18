hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

local gridActions = require("grid")
local terminal = require("terminal")
local window = require("windows")

hs.logger.defaultLogLevel = "info"
hs.window.animationDuration = 0

-- modifier keys (note: [ hyper + . ] is reserved for macos sysdiagnose!
local meh = { "shift", "ctrl", "alt" }
local hyper = { "shift", "ctrl", "alt", "cmd" }

hs.grid.setMargins("8,8") -- keep some space between windows
gridActions.setAllGrids(4) -- set each screen's grid to 4x its aspect ratio
hs.hotkey.bind(meh, "[", function() gridActions.setAllGrids(-1, true) end)
hs.hotkey.bind(meh, "]", function() gridActions.setAllGrids(1, true) end)

-- [[ ONCE-PER-KEYPRESS HOTKEYS ]]
local singleUseActions = {
  { meh, "space", terminal.toggle },

  { meh, "6", window.pane.split },
  { meh, "7", window.pane.swap },
  { meh, "8", window.layout.toggle },
  { meh, "9", window.pane.float },

  { meh, "0", window.pane.super },

  { hyper, "6", window.layout.flip },
  { hyper, "7", window.layout.rotate },
  { hyper, "8", window.layout.balance },
  { hyper, "9", window.layout.reset },

  { meh, "h", window.pane.focusWest },
  { meh, "j", window.pane.focusSouth },
  { meh, "k", window.pane.focusNorth },
  { meh, "l", window.pane.focusEast },

  { hyper, "h", window.space.focusWest },
  { hyper, "l", window.space.focusEast },

  { meh, "n", gridActions.rotate },
  { meh, "m", gridActions.scaleDown },
  { meh, ",", gridActions.scaleUp },
  { meh, ".", gridActions.center },

  { meh, "/", hs.grid.maximizeWindow },
  { meh, "\\", gridActions.moveToNextScreen },

  { hyper, "p", window.presets },
  { hyper, "0", window.focus },
}
for _, v in ipairs(singleUseActions) do
  hs.hotkey.bind(v[1], v[2], function() v[3]() end)
end

-- [[ REPEAT-WHEN-HELD HOTKEYS ]]
local repeatableActions = {
  -- moving windows
  { meh, "y", hs.grid.pushWindowLeft },
  { meh, "u", hs.grid.pushWindowDown },
  { meh, "i", hs.grid.pushWindowUp },
  { meh, "o", hs.grid.pushWindowRight },
  -- resizing windows
  { hyper, "y", hs.grid.resizeWindowThinner },
  { hyper, "u", hs.grid.resizeWindowTaller },
  { hyper, "i", hs.grid.resizeWindowShorter },
  { hyper, "o", hs.grid.resizeWindowWider },
}
for _, v in ipairs(repeatableActions) do
  hs.hotkey.bind(v[1], v[2], function() v[3]() end, nil, function() v[3]() end)
end
