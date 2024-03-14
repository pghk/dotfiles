hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

local gridActions = require("grid")
local terminal = require("terminal")
local window = require("windows")

local defaultGridMargins = "8,8"
hs.logger.defaultLogLevel = "info"
hs.window.animationDuration = 0

-- modifier keys (note: [ hyper + . ] is reserved for macos sysdiagnose!
local mash = { "shift", "ctrl", "alt" }
local hyper = { "shift", "ctrl", "alt", "cmd" }

-- Toggle terminal window
hs.hotkey.bind(mash, "space", function() terminal.toggle() end)

-- Allow keyboard to move mouse across screens, to help with app-switching
local moveMouseOneScreen = function(direction)
  local screen = hs.mouse.getCurrentScreen()
  local map = {
    west = screen:toWest(),
    east = screen:toEast(),
  }
  local destination = map[direction]
  hs.mouse.setRelativePosition({ x = 0, y = 0 }, destination)
end

-- Ensure that mouse stays on the same screen as apps activated via alt-tab
local appFocusEventHandler = function(appName, event, application)
  if event ~= hs.application.watcher.activated then
    return
  end

  local appWindow = application:focusedWindow()
  if appWindow == nil then
    return
  end

  local appScreen = appWindow:screen()
  if appScreen == nil then
    return
  end

  local mouseScreen = hs.mouse.getCurrentScreen()
  if appScreen:id() ~= mouseScreen:id() then
    local destFrame = appWindow:frame()
    local newX = destFrame.x + (destFrame.w * 0.8)
    local newY = destFrame.y + 12
    hs.mouse.absolutePosition({ x = newX, y = newY })
  end
end
-- Store watcher in a global, so it doesn't get garbage collected
mouseFollowAppWatcher = hs.application.watcher.new(appFocusEventHandler)
mouseFollowAppWatcher:start()

--[[ 

*** Window Management ***

]]

hs.grid.setMargins(defaultGridMargins) -- set margins between windows
gridActions.setAllGrids(4) -- set each screen's grid to 4x its aspect ratio

-- [[ ONCE-PER-KEYPRESS HOTKEYS ]]
local singleUseActions = {
  { mash, "n", function() gridActions.rotate() end },
  { mash, "m", function() gridActions.scaleDown() end },
  { mash, ",", function() gridActions.scaleUp() end },
  { mash, ".", function() gridActions.center() end },

  { mash, "/", function() hs.grid.maximizeWindow() end },
  { mash, "[", function() gridActions.setAllGrids(-1, true) end },
  { mash, "]", function() gridActions.setAllGrids(1, true) end },
  { mash, "\\", function() gridActions.moveToNextScreen() end },

  { mash, "left", function() gridActions.moveToLeftHalf() end },
  { mash, "right", function() gridActions.moveToRightHalf() end },
  { mash, "up", function() gridActions.moveToVisor() end },
  { mash, "down", function() gridActions.fitBelowVisor() end },

  { hyper, "left", function() moveMouseOneScreen("west") end },
  { hyper, "right", function() moveMouseOneScreen("east") end },
}
for _, v in ipairs(singleUseActions) do
  hs.hotkey.bind(v[1], v[2], v[3])
end

-- [[ REPEAT-WHEN-HELD HOTKEYS ]]
local repeatableActions = {
  -- moving windows
  { mash, "h", hs.grid.pushWindowLeft },
  { mash, "j", hs.grid.pushWindowDown },
  { mash, "k", hs.grid.pushWindowUp },
  { mash, "l", hs.grid.pushWindowRight },
  -- resizing windows
  { hyper, "h", hs.grid.resizeWindowThinner },
  { hyper, "j", hs.grid.resizeWindowTaller },
  { hyper, "k", hs.grid.resizeWindowShorter },
  { hyper, "l", hs.grid.resizeWindowWider },
}
for _, v in ipairs(repeatableActions) do
  hs.hotkey.bind(v[1], v[2], function() window.sticky(v[3]) end, nil, function() window.sticky(v[3]) end)
end
