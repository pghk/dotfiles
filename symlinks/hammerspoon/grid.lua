-- Helper for aspect ratio calculation
function greatestCommonDivisor(a, b)
  while b ~= 0 do a,b = b,(a % b) end
  return a
end

-- Calulates aspect ratio for a given screen resolution
function aspectRatio(x, y)
  local div = greatestCommonDivisor(x, y)
  return math.floor(x / div), math.floor(y / div)
end

-- Constructs a geometry object from a given screen's aspect ratio
function makeGrid(screen)
  local mode = screen:currentMode()
  return hs.geometry(nil, nil, aspectRatio(mode.w, mode.h))
end

--[[ Partitions every screen for the purposes of window management.
Each grid is based on the screen's aspect ratio, multiplied by a given factor.
For example, on a 16x9 screen:
  - 1x: 16 columns by 9 rows
  - 2x: 32 colummns by 18 rows
]]
function setAllGrids(factor)
  for key, screen in pairs(hs.screen.allScreens()) do
    local newGrid = makeGrid(screen)
    newGrid.w = newGrid.w * factor
    newGrid.h = newGrid.h * factor
    hs.grid.setGrid(newGrid, screen)
    hs.alert.show(' ' .. newGrid.w .. ' x ' .. newGrid.h, screen)
  end
end

-- Resizes the current focused window to the provided dimensions (in grid cells)
function resizeWindow(newWidth, newHeight)
  function newSize(cell)
    cell.w = newWidth
    cell.h = newHeight
  end
  hs.grid.adjustWindow(newSize, hs.window.focusedWindow())
end

--[[ Resizes the window to a given dimension, relative to a 8-cell-wide grid
For example, on a 32 x 18 grid, an argument of {w=4, h=3} would result in a new window size of 16 x 12
]]
function smartResize(aspect)
  local window = hs.window.focusedWindow()
  local factor = hs.grid.getGrid(window:screen()).w / 8
  newWidth = math.ceil(aspect.w * factor)
  newHeight = math.floor(aspect.h * factor)
  resizeWindow(newWidth, newHeight)
end

--[[ Resizes the current focused window to a size that equals what you would get if you took one side of the screen and rotated it 90 degrees ]]
function cleverResize()
  local window = hs.window.focusedWindow()
  local grid = hs.grid.getGrid(window:screen())
  newWidth = grid.h
  newHeight = grid.w / 2
  resizeWindow(newWidth, newHeight)
end

function moveWindowToNextScreen()
  local window = hs.window.focusedWindow()
  window:moveToScreen(window:screen():next()) 
end

-- debugging helper
 function getWindowInfo()
  local window = hs.window.focusedWindow()
  print(hs.grid.getGrid(hs.screen.mainScreen()))
  print(hs.grid.get(window))
end
