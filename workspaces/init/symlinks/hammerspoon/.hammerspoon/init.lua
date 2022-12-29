local gridActions = require("grid")
local terminalActions = require("terminal")
local defaultGridMargins = "8,8"
hs.logger.defaultLogLevel = 'info'
hs.window.animationDuration = 0

-- modifier keys (note: [ hyper + . ] is reserved for macos sysdiagnose!
local mash = {"shift", "ctrl", "alt"}
local hyper = {"shift", "ctrl", "alt", "cmd"}

-- hotkey to reload Hammerspoon configuration
local reloadConfig = function()
  hs.reload()
  hs.notify.new( {
    title = "Hammerspoon",
    informativeText = "Config reloaded"
  }
  ):send()
end
hs.hotkey.bind(mash, "f12", function() reloadConfig() end)

-- Toggle terminal window
hs.hotkey.bind(mash, 'space', function() terminalActions.toggle() end)

--[[ 

*** Window Management ***

]]
hs.grid.setMargins(defaultGridMargins) -- set margins between windows
gridActions.setAllGrids(0) -- set each screen's grid to its aspect ratio

-- [[ ONCE-PER-KEYPRESS HOTKEYS ]]
local singleUseActions = {
  { mash, 'n', function() gridActions.rotate() end },
  { mash, 'm', function() gridActions.scaleDown() end },
  { mash, ',', function() gridActions.scaleUp() end },
  { mash, '.', function() gridActions.center() end },

  { mash, '/', function() hs.grid.maximizeWindow() end },
  { mash, '[', function() gridActions.setAllGrids(-1, true) end },
  { mash, ']', function() gridActions.setAllGrids(1, true) end },
  { mash, '\\', function() gridActions.moveToNextScreen() end },

  { mash, 'left', function() gridActions.moveToLeftHalf() end },
  { mash, 'right', function() gridActions.moveToRightHalf() end },
  { mash, 'up', function() gridActions.moveToVisor() end },
  { mash, 'down', function() gridActions.fitBelowVisor() end },
}
for _,v in ipairs(singleUseActions) do
  hs.hotkey.bind(v[1], v[2], v[3])
end

-- [[ REPEAT-WHEN-HELD HOTKEYS ]] 
local repeatableActions = {
  -- moving windows
  { mash, 'h', function() hs.grid.pushWindowLeft() end },
  { mash, 'j', function() hs.grid.pushWindowDown() end },
  { mash, 'k', function() hs.grid.pushWindowUp() end },
  { mash, 'l', function() hs.grid.pushWindowRight() end },
  -- resizing windows
  { hyper, 'h', function() hs.grid.resizeWindowThinner() end },
  { hyper, 'j', function() hs.grid.resizeWindowTaller() end },
  { hyper, 'k', function() hs.grid.resizeWindowShorter() end },
  { hyper, 'l', function() hs.grid.resizeWindowWider() end }
}
for _,v in ipairs(repeatableActions) do
  hs.hotkey.bind(v[1], v[2], v[3], nil, v[3])
end


