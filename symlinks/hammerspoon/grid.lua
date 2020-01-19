function greatestCommonDivisor(a, b)
  while b ~= 0 do a,b = b,(a % b) end
  return a
end

function aspectRatio(x, y)
  local div = greatestCommonDivisor(x, y)
  return math.floor(x / div), math.floor(y / div)
end

function makeGrid(screen)
  local mode = screen:currentMode()
  return hs.geometry(nil, nil, aspectRatio(mode.w, mode.h))
end

function setAllGrids(factor)
  for key, screen in pairs(hs.screen.allScreens()) do
    local newGrid = makeGrid(screen)
    newGrid.w = newGrid.w * factor
    newGrid.h = newGrid.h * factor
    hs.grid.setGrid(newGrid, screen)
    hs.alert.show(' ' .. newGrid.w .. ' x ' .. newGrid.h, screen)
  end
end

function resizeWindow(newWidth, newHeight)
  function newSize(cell)
    cell.w = newWidth
    cell.h = newHeight
  end
  hs.grid.adjustWindow(newSize, hs.window.focusedWindow())
end

function smartResize(aspect)
  local factor = hs.grid.getGrid(hs.screen.mainScreen()).w / 8
  newWidth = math.ceil(aspect.w * factor)
  newHeight = math.floor(aspect.h * factor)
  resizeWindow(newWidth, newHeight)
end

function cleverResize()
  local grid = hs.grid.getGrid(hs.screen.mainScreen())
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
