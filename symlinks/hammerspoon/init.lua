hs.logger.defaultLogLevel = 'info'
defaultGridMargins = "8,8"
hs.window.animationDuration = 0.05

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
hs.hotkey.bind(mash, "f13", function() reloadConfig() end)

--[[ 

  *** Window Management ***

]]
require "grid"
hs.grid.setMargins(defaultGridMargins) -- set margins between windows
setAllGrids(1) -- initially set the grid of each screen to its aspect ratio

-- [[ ONCE-PER-KEYPRESS HOTKEYS ]]
local singleUseActions = {
  -- preset window sizes:
  ["."] = function() hs.grid.maximizeWindow() end, -- full screen
  m = function() cleverResize() end, -- medium
  [","] = function() smartResize({w=4, h=3}) end, -- small, landscape
  ["/"] = function() smartResize({w=3, h=4}) end, -- small, portrait
  -- change window grids:
  ["["] = function() setAllGrids(1) end, -- default
  ["]"] = function() setAllGrids(2) end, -- 2x (for centering)
  -- move window to next screen:
  ["\\"] = function() moveWindowToNextScreen() end,
  -- print grid info of current window to console:
  -- ? = function() getWindowInfo() end
}
for key, action in pairs(singleUseActions) do
  hs.hotkey.bind(mash, key, action)
end

-- [[ REPEAT-WHEN-HELD HOTKEYS ]] 
local repeatableActions = {
  -- moving windows
  left = function() hs.grid.pushWindowLeft() end,
  right = function() hs.grid.pushWindowRight() end,
  up = function() hs.grid.pushWindowUp() end,
  down = function() hs.grid.pushWindowDown() end,
  -- resizing windows
  i = function() hs.grid.resizeWindowShorter() end,
  k = function() hs.grid.resizeWindowTaller() end,
  j = function() hs.grid.resizeWindowThinner() end,
  l = function() hs.grid.resizeWindowWider() end
}
for key, action in pairs(repeatableActions) do
  hs.hotkey.bind(mash, key, action, nil, action)
end




