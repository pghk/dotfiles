local M = {}

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

--[[ Partitions every screen for the purposes of window management.
Each grid is based on the screen's aspect ratio, magnified by a given factor.
For example, 1x = 16:9, 2x = 32:18.
]]
local gridResolutionFactor = 1
M.setAllGrids = function(increment, report)
  report = report or false
  gridResolutionFactor = gridResolutionFactor + increment
  local function setGrid(screen)
    local newGrid = makeGrid(screen)
    newGrid.w = newGrid.w * gridResolutionFactor
    newGrid.h = newGrid.h * gridResolutionFactor
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

M.rotate = function(window)
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

M.center = function(window)
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
  M.center(window)
end

local function getOrientation(window)
  window = window or hs.window.focusedWindow()
  local current = hs.grid.get(window)
  if not current then
    return nil
  end
  return current.w < current.h and "portrait" or "landscape"
end

M.scaleUp = function(window)
  window = window or hs.window.focusedWindow()
  local orientation = getOrientation(window)
  if orientation == "landscape" then
    magicResize({ w = 1, h = 2 })
  elseif orientation == "portrait" then
    magicResize({ w = 2, h = 1 })
  end
end

M.scaleDown = function(window)
  window = window or hs.window.focusedWindow()
  local orientation = getOrientation(window)
  if orientation == "landscape" then
    magicResize({ w = 0.5, h = 1 })
  elseif orientation == "portrait" then
    magicResize({ w = 1, h = 0.5 })
  end
end

M.moveToNextScreen = function(window)
  window = window or hs.window.focusedWindow()
  window:moveToScreen(window:screen():next())
end

M.moveToRightHalf = function(window)
  window = window or hs.window.focusedWindow()
  local max = hs.grid.getGrid(window:screen())
  if not max then
    return
  end
  local new = { x = max.w / 2, y = 0, w = max.w / 2, h = max.h }
  hs.grid.set(window, new)
end

M.moveToLeftHalf = function(window)
  window = window or hs.window.focusedWindow()
  local max = hs.grid.getGrid(window:screen())
  if not max then
    return
  end
  local new = { x = 0, y = 0, w = max.w / 2, h = max.h }
  hs.grid.set(window, new)
end

local visorHeight = 0.33
M.moveToVisor = function(window)
  window = window or hs.window.focusedWindow()
  local max = hs.grid.getGrid(window:screen())
  if not max then
    return
  end
  local offset = max.h * visorHeight
  local new = { x = 0, y = 0, w = max.w, h = offset }
  hs.grid.set(window, new)
end

M.fitBelowVisor = function(window)
  window = window or hs.window.focusedWindow()
  local current = hs.grid.get(window)
  local max = hs.grid.getGrid(window:screen())
  if not max or not current then
    return
  end
  local offset = max.h * visorHeight
  local new = { x = current.x, y = offset, w = current.w, h = max.h - offset }
  hs.grid.set(window, new)
end

return M
