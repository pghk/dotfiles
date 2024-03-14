local M = {}

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

return M
