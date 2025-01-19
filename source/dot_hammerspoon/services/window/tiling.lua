-- inspo: https://github.com/szymonkaliski/hhtwm/blob/master/hhtwm/init.lua
local M = { filter = {} }

-- Speed up window queries by 10s
-- https://github.com/Hammerspoon/hammerspoon/issues/2943#issuecomment-2105644391
local ignoreApps = {
  "Raycast Web Content",
  "Kaleidoscope Web Content",
}
for _, name in ipairs(ignoreApps) do
  hs.window.filter.ignoreAlways[name] = true
end

local function moveMouseToFrame(frame)
  local newX = frame.x + (frame.w * 0.618)
  local newY = frame.y + (frame.h * 0.382)
  hs.mouse.absolutePosition({ x = newX, y = newY })
end

local function focusNext(windows)
  if #windows == 0 then
    return
  end

  ---@class hs.window
  ---@field application hs.application
  local win = windows[1]
  win:becomeMain()
  win:application():activate()
  win:focus()
  moveMouseToFrame(win:frame())
end

local function getFirstWindowFromOtherScreen()
  for _, window in ipairs(M.filter:getWindows() or {}) do
    if window:screen() ~= hs.screen.mainScreen() then
      return window
    end
  end
end

---@param window hs.window
local function bringWindowToCursor(window)
  window:moveToScreen(hs.mouse.getCurrentScreen() or hs.screen.mainScreen())
end

---@param windows hs.window[]
local function swap(windows)
  if #windows < 2 then
    return
  end

  local cur, prev = table.unpack(windows)
  local a = cur:frame()
  local b = prev:frame()

  prev:move(a)
  cur:move(b)
  moveMouseToFrame(b)
  cur:focus()
end

M.actions = {
  focusNorth = function()
    focusNext(M.filter:windowsToNorth())
  end,

  focusSouth = function()
    focusNext(M.filter:windowsToSouth())
  end,

  focusEast = function()
    focusNext(M.filter:windowsToEast())
  end,

  focusWest = function()
    focusNext(M.filter:windowsToWest())
  end,

  pullWindow = function()
    local window = getFirstWindowFromOtherScreen() or hs.window.allWindows()[2]
    bringWindowToCursor(window)
    window:focus()
  end,

  pushWindow = function()
    local window = hs.window.frontmostWindow()
    window:moveToScreen(hs.screen.mainScreen():next())
  end,

  swapWindows = function()
    swap(M.filter:getWindows())
  end,

  mouseNextScreen = function()
    ---@class hs.screen
    local screen = hs.mouse.getCurrentScreen()
    moveMouseToFrame(screen:next():frame())
  end,
}

M.start = function()
  M.filter = hs.window.filter.new():setDefaultFilter():setOverrideFilter({
    currentSpace = true,
    visible = true,
    fullscreen = false,
    allowRoles = { "AXStandardWindow" },
  })
  -- M.filter:subscribe({ hs.window.filter.windowFocused, hs.window.filter.windowUnhidden })
end

M.stop = function()
  M.filter:unsubscribeAll()
end

return M
