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

  { meh, "n", gridActions.rotate },
  { meh, "m", gridActions.scaleDown },
  { meh, ",", gridActions.scaleUp },
  { meh, ".", gridActions.center },

  { meh, "/", hs.grid.maximizeWindow },
  { meh, "\\", gridActions.moveToNextScreen },

  { meh, "left", gridActions.moveToLeftHalf },
  { meh, "right", gridActions.moveToRightHalf },
  { meh, "up", gridActions.moveToVisor },
  { meh, "down", gridActions.fitBelowVisor },

  { hyper, "p", window.presets },
  { hyper, "8", window.focus },
  { hyper, "6", window.test },
}
for _, v in ipairs(singleUseActions) do
  hs.hotkey.bind(v[1], v[2], function() v[3]() end)
end

-- [[ REPEAT-WHEN-HELD HOTKEYS ]]
local repeatableActions = {
  -- moving windows
  { meh, "h", hs.grid.pushWindowLeft },
  { meh, "j", hs.grid.pushWindowDown },
  { meh, "k", hs.grid.pushWindowUp },
  { meh, "l", hs.grid.pushWindowRight },
  -- resizing windows
  { hyper, "h", hs.grid.resizeWindowThinner },
  { hyper, "j", hs.grid.resizeWindowTaller },
  { hyper, "k", hs.grid.resizeWindowShorter },
  { hyper, "l", hs.grid.resizeWindowWider },
}
for _, v in ipairs(repeatableActions) do
  hs.hotkey.bind(v[1], v[2], function() v[3]() end, nil, function() v[3]() end)
end
