local module = {}

ODD_HEIGHTS = { [1117] = "MBP_16", [982] = "MBP_14" }
NOTCH_STATUS_BAR = 37

local function hasNotch(h) return ODD_HEIGHTS[h] ~= nil end

local function greatestCommonDivisor(a, b)
  while b ~= 0 do
    a, b = b, (a % b)
  end
  return a
end

-- Calculates aspect ratio for a given screen resolution
local function aspectRatio(x, y)
  local div = greatestCommonDivisor(x, y)
  return math.floor(x / div), math.floor(y / div)
end

-- Constructs a geometry object from a given screen's aspect ratio
local function makeGrid(screen)
  local mode = screen:currentMode()
  if hasNotch(mode.h) then
    mode.h = mode.h - NOTCH_STATUS_BAR
  end
  return hs.geometry(nil, nil, aspectRatio(mode.w, mode.h))
end

-- Builds a function to resize the given grid cell to the provided dimensions
local function getResizer(width, height)
  return function(cell)
    cell.w = width
    cell.h = height
  end
end

local function resize(window, width, height)
  window = window or hs.window.focusedWindow()
  local resizer = getResizer(width, height)
  return hs.grid.adjustWindow(resizer, window)
end

local function flipScale(window, scale)
  window = window or hs.window.focusedWindow()
  local current = hs.grid.get(window)
  if not current then
    return nil
  end
  local newWidth = current.h * scale.h
  local newHeight = current.w * scale.w
  resize(window, newWidth, newHeight)
end

local function magicResize(scale)
  local window = hs.window.focusedWindow()
  flipScale(window, scale)
  module.center(window)
end

local function getOrientation(window)
  window = window or hs.window.focusedWindow()
  local current = hs.grid.get(window)
  if not current then
    return nil
  end
  return current.w < current.h and "portrait" or "landscape"
end

module.rotate = function(window)
  window = window or hs.window.focusedWindow()
  local current = hs.grid.get(window)
  if not current then
    return nil
  end
  local new = {
    x = current.x + ((current.w - current.h) / 2),
    y = current.y + ((current.h - current.w) / 2),
    w = current.h,
    h = current.w,
  }
  hs.grid.set(window, new)
end

module.center = function(window)
  window = window or hs.window.focusedWindow()
  local current = hs.grid.get(window)
  local max = hs.grid.getGrid(window:screen())
  if not max or not current then
    return nil
  end
  local new = {
    x = math.ceil(max.w / 2 - current.w / 2),
    y = math.floor(max.h / 2 - current.h / 2),
    w = current.w,
    h = current.h,
  }
  hs.grid.set(window, new)
end

module.grow = function(window)
  window = window or hs.window.focusedWindow()
  local orientation = getOrientation(window)
  if orientation == "landscape" then
    magicResize({ w = 1, h = 2 })
  elseif orientation == "portrait" then
    magicResize({ w = 2, h = 1 })
  end
end

module.shrink = function(window)
  window = window or hs.window.focusedWindow()
  local orientation = getOrientation(window)
  if orientation == "landscape" then
    magicResize({ w = 0.5, h = 1 })
  elseif orientation == "portrait" then
    magicResize({ w = 1, h = 0.5 })
  end
end

module.moveToNextScreen = function(window)
  window = window or hs.window.focusedWindow()
  window:moveToScreen(window:screen():next())
end

module.moveLeft = hs.grid.pushWindowLeft
module.moveDown = hs.grid.pushWindowDown
module.moveUp = hs.grid.pushWindowUp
module.moveRight = hs.grid.pushWindowRight
module.makeThinner = hs.grid.resizeWindowThinner
module.makeTaller = hs.grid.resizeWindowTaller
module.makeShorter = hs.grid.resizeWindowShorter
module.makeWider = hs.grid.resizeWindowWider
module.maximize = hs.grid.maximizeWindow

--[[
   Experimental
]]

local getPosition = function(relative, toScreen)
  local max = hs.grid.getGrid(toScreen) or { w = 0, h = 0 }
  return {
    x = max.w * relative.x,
    y = max.h * relative.y,
    w = max.w * (relative.w or (1 - relative.x)),
    h = max.h * (relative.h or (1 - relative.y)),
  }
end

local presets = {
  ["Microsoft Teams (work or school)"] = { x = 1 / 8, y = 0 },
  ["Mail"] = { x = 0, y = 0 },
}

module.presets = function()
  for _, window in pairs(hs.window.visibleWindows() or {}) do
    local application = window:application() or { title = "" }
    local app = application:title()
    if presets[app] ~= nil then
      local pos = getPosition(presets[app], window:screen())
      hs.grid.set(window, pos)
    end
  end
end

local cascade = function(index, count)
  local rect = { x = 0, y = 0, w = 1, h = 1 }
  if count > 1 then
    local size = 1 / (count * 0.535)
    local offset = (count - index) * ((1 - size) / (count - 1))
    rect = { x = offset, y = offset, w = size, h = size }
  end
  return rect
end

module.focus = function()
  local screens = hs.screen.allScreens() or {}
  local thisWindow = hs.window.focusedWindow()
  local others = {}
  local count = 0
  for _, v in pairs(hs.window.orderedWindows() or {}) do
    if v ~= thisWindow and v:isStandard() and v:isVisible() then
      count = count + 1
      others[count] = v
    end
  end

  for i, window in ipairs(others or {}) do
    local pos = getPosition(cascade(i, count), screens[2])
    hs.grid.set(window, pos, screens[2])
  end
end

--[[
    Partitions every screen for the purposes of window management.
    Each grid is proportional to the screen's aspect ratio, multiplied to a
    given granularity level. For example: 1x = 16:9, 2x = 32:18.
]]
SetGridGranularity = function(level, report)
  report = report or false
  local function setGrid(screen)
    local newGrid = makeGrid(screen)
    newGrid.w = newGrid.w * level
    newGrid.h = newGrid.h * level
    local message = newGrid.w .. " x " .. newGrid.h
    if report then
      hs.alert.show(message, screen)
    end
    hs.grid.setGrid(newGrid, screen)
  end
  for _, screen in pairs(hs.screen.allScreens() or {}) do
    setGrid(screen)
  end
end

return module
