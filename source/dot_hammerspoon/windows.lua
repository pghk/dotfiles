local M = {}

local debug = function()
  for _, screen in pairs(hs.screen.allScreens() or {}) do
    print(hs.inspect.inspect(screen))
  end
  for _, window in pairs(hs.window.visibleWindows() or {}) do
    print(hs.inspect.inspect(window:application()))
  end
end

M.sticky = function(motion)
  local thisWindow = hs.window.focusedWindow()
  local rect = { x = 0, y = 0, w = 0, h = 0 }

  local others = {}
  for k, v in pairs(thisWindow:otherWindowsSameScreen()) do
    if v:isStandard() then
      others[k] = v
    end
  end

  local prev = hs.grid.get(thisWindow) or rect
  motion()
  local next = hs.grid.get(thisWindow) or rect

  local isNeighborEast = function(a, b) return a.x + a.w == b.x end
  local isNeighborWest = function(a, b) return b.x + b.w == a.x end
  local isNeighborSouth = function(a, b) return a.y + a.h == b.y end
  local isNeighborNorth = function(a, b) return b.y + b.h == a.y end

  local hasMovedOnWest = function(a, b) return a.x ~= b.x end
  local hasMovedOnNorth = function(a, b) return a.y ~= b.y end

  for _, window in pairs(others) do
    local other = hs.grid.get(window) or rect
    local adjust
    if isNeighborEast(prev, other) then
      -- Move neighbor's West border in step with our East, and transfer width
      adjust = function(cell)
        cell.x = next.x + next.w
        cell.w = cell.w + (prev.w - next.w)
      end
    end
    if isNeighborWest(prev, other) and hasMovedOnWest(prev, next) then
      -- Transfer width, implicitly moving neighbor's East border
      adjust = function(cell) cell.w = cell.w + (prev.w - next.w) end
    end
    if isNeighborSouth(prev, other) then
      -- Move neighbor's N border in step with our S, and transfer height
      adjust = function(cell)
        cell.y = next.y + next.h
        cell.h = cell.h + (prev.h - next.h)
      end
    end
    if isNeighborNorth(prev, other) and hasMovedOnNorth(prev, next) then
      -- Transfer height, implicitly moving neighbor's South border
      adjust = function(cell) cell.h = cell.h + (prev.h - next.h) end
    end
    if adjust ~= nil then
      hs.grid.adjustWindow(adjust, window)
    end
  end
end

local resize = function(relative, screen)
  local max = hs.grid.getGrid(screen) or { w = 0, h = 0 }
  return {
    x = max.w * relative.x,
    y = max.h * relative.y,
    w = max.w * (relative.w or (1 - relative.x)),
    h = max.h * (relative.h or (1 - relative.y)),
  }
end

local function moveAndSize(window, screen, spec) hs.grid.set(window, resize(spec, screen), screen) end

local presets = {
  ["Microsoft Teams (work or school)"] = { x = 1 / 8, y = 0 },
  ["Mail"] = { x = 0, y = 0 },
}

M.presets = function()
  for _, window in pairs(hs.window.visibleWindows() or {}) do
    local application = window:application() or { title = "" }
    local app = application:title()
    if presets[app] ~= nil then
      local new = resize(presets[app], window:screen())
      hs.grid.set(window, new)
    end
  end
end

M.layout = function()
  local windows = hs.window.orderedWindows() or {}
  local screens = hs.screen.allScreens() or {}
  if #windows < 1 then
    return
  end
  if #screens < 2 then
    return
  end

  if #windows == 2 then
    moveAndSize(windows[1], screens[1], { x = 0, y = 0 })
    moveAndSize(windows[2], screens[2], { x = 0, y = 0 })
  end

  if #windows == 3 then
    moveAndSize(windows[1], screens[1], { x = 0, y = 0, w = 0.618 })
    moveAndSize(windows[2], screens[2], { x = 0, y = 0 })
    moveAndSize(windows[3], screens[1], { x = 0.618, y = 0 })
  end

  if #windows == 4 then
    moveAndSize(windows[1], screens[1], { x = 0, y = 0, w = 0.5 })
    moveAndSize(windows[2], screens[2], { x = 0, y = 0 })
    moveAndSize(windows[3], screens[1], { x = 0.5, y = 0, h = 0.5 })
    moveAndSize(windows[4], screens[1], { x = 0.5, y = 0.5 })
  end

  if #windows == 5 then
    moveAndSize(windows[1], screens[1], { x = 0, y = 0, w = 0.5 })
    moveAndSize(windows[2], screens[1], { x = 0.5, y = 0, h = 0.5 })
    moveAndSize(windows[3], screens[1], { x = 0.5, y = 0.5 })
    moveAndSize(windows[4], screens[2], { x = 0, y = 0, w = 0.5 })
    moveAndSize(windows[5], screens[2], { x = 0.5, y = 0 })
  end
end

M.layout2 = function()
  local screens = hs.screen.allScreens() or {}
  local window = hs.window.focusedWindow()
  local others = {}
  local count = 0
  for _, v in pairs(window:otherWindowsAllScreens() or {}) do
    if v:isStandard() then
      count = count + 1
      others[count] = v
    end
  end

  moveAndSize(window, screens[1], {
    x = 1 / 16,
    y = 1 / 36,
    w = 14 / 16,
    h = 33 / 36,
  })

  local rows = 2
  if count <= 2 then
    rows = 1
  end

  local top = math.floor(count / 2)
  local bottom = count - top

  for i, v in ipairs(others or {}) do
    local new = {}
    if count <= 2 then
      new = { x = (i - 1) * (1 / count), y = 0, h = 1, w = 1 / count }
    elseif i <= top then
      local offset = i - 1
      new = { x = (1 / top) * offset, y = 0, h = 1 / rows, w = 1 / top }
    else
      local offset = (i - top) - 1
      new = { x = (1 / bottom) * offset, y = 0.5, h = 1 / rows, w = 1 / bottom }
    end
    moveAndSize(v, screens[2], new)
  end
end

return M
