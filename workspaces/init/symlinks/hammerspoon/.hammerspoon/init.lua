hs.logger.defaultLogLevel = 'info'
defaultGridMargins = "8,8"
hs.window.animationDuration = 0

-- modifier keys (note: [ hyper + . ] is reserved for macos sysdiagnose!
mash = {"shift", "ctrl", "alt"}
hyper = {"shift", "ctrl", "alt", "cmd"}

-- hotkey to reload Hammerspoon configuration
local reloadConfig = function()
  hs.reload()
  hs.notify.new(
    {
      title = "Hammerspoon",
      informativeText = "Config reloaded"
    }
  ):send()
end
hs.hotkey.bind(mash, "f12", function() reloadConfig() end)

--[[ 

  *** Window Management ***

]]
require "grid"
hs.grid.setMargins(defaultGridMargins) -- set margins between windows
setAllGrids(1) -- initially set the grid of each screen to its aspect ratio

-- [[ ONCE-PER-KEYPRESS HOTKEYS ]]
local singleUseActions = {
  -- preset window sizes:
  { mash, '/', function() hs.grid.maximizeWindow() end }, -- full screen
  { mash, 'm', function() cleverResize() end, }, -- medium
  { mash, ',', function() smartResize({w=6, h=4}) end }, -- small, landscape
  { mash, '.', function() smartResize({w=4, h=6}) end }, -- small, portrait
  -- change window grids:
  { mash, '[', function() setAllGrids(1, true) end }, -- default
  { mash, ']', function() setAllGrids(2, true) end }, -- 2x (for centering)
  -- move window to next screen:
  { mash, '\\', function() moveWindowToNextScreen() end }
}
for k,v in ipairs(singleUseActions) do
  hs.hotkey.bind(v[1], v[2], v[3])
end

-- [[ REPEAT-WHEN-HELD HOTKEYS ]] 
local repeatableActions = {
  -- moving windows
  { mash, 'up', function() hs.grid.pushWindowUp() end },
  { mash, 'down', function() hs.grid.pushWindowDown() end },
  { mash, 'left', function() hs.grid.pushWindowLeft() end },
  { mash, 'right', function() hs.grid.pushWindowRight() end },
  -- resizing windows
  { hyper, 'up', function() hs.grid.resizeWindowShorter() end },
  { hyper, 'down', function() hs.grid.resizeWindowTaller() end },
  { hyper, 'left', function() hs.grid.resizeWindowThinner() end },
  { hyper, 'right', function() hs.grid.resizeWindowWider() end }
}
for k,v in ipairs(repeatableActions) do
  hs.hotkey.bind(v[1], v[2], v[3], nil, v[3])
end




