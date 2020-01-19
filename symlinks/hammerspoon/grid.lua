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

--[[
reFrame resizes windows

@param gw grid width, as a divisor of total screen width
@param gh grid height, as a divisor of total screen height

@param w new width, as a dividend of grid width
@param h new height, as a dividend of grid height

@param x left padding, as divisor of the remaining horizontal space
@param y top padding, as divisor of the remaining verital space
--]]
function reFrame(new_size, new_grid, margins, position)
  local win = getWin()
  local screen = win:screen()

  local current = win:frame()
  local field = screen:frame()

  local new = {}
  new.w = field.w * new_size.w / new_grid.x - margins.w
  new.h = field.h * new_size.h / new_grid.y - margins.h
  new.x = field.w / (new_grid.x * position.x) + margins.w / 2
  new.y = field.h / (new_grid.y * position.y) + margins.h / 2 + title_bar_height
  
  hs.grid.setMargins(hs.geometry(nil, nil, margins.w, margins.h))
  hs.grid.setGrid(hs.geometry(nil, nil, new_grid.x, new_grid.y))

  print(hs.geometry(new))
  return new
end

hs.hotkey.bind(mash, "z", function() 
  hs.grid.setGrid('1x1')
  hs.grid.setMargins('120,0')
  hs.alert.show('Aspect ratio 4:3')
end)

--- arrows: move window
local windowMovements = {
  left = function() hs.grid.pushWindowLeft() end,
  right = function() hs.grid.pushWindowRight() end,
  up = function() hs.grid.pushWindowUp() end,
  down = function() hs.grid.pushWindowDown() end
}
for key, action in pairs(windowMovements) do
  hs.hotkey.bind(mash, key, action, nil, action)
end

--- ikjl: resize window
local windowSizers = {
  i = function() hs.grid.resizeWindowShorter() end,
  k = function() hs.grid.resizeWindowTaller() end,
  j = function() hs.grid.resizeWindowThinner() end,
  l = function() hs.grid.resizeWindowWider() end,
}
for key, action in pairs(windowSizers) do
  hs.hotkey.bind(mash, key, action, nil, action)
end

--- 234: resize grid
hs.hotkey.bind(mash, "1", function() hs.grid.setGrid('12x16'); hs.alert.show('Grid set to 12x16'); end)
hs.hotkey.bind(mash, "2", function() hs.grid.setGrid('2x2'); hs.alert.show('Grid set to 2x2'); end)
hs.hotkey.bind(mash, "3", function() hs.grid.setGrid('3x2'); hs.alert.show('Grid set to 3x2'); end)
hs.hotkey.bind(mash, "4", function() hs.grid.setGrid('4x2'); hs.alert.show('Grid set to 4x2'); end)
hs.hotkey.bind(mash, "5", function() hs.grid.setGrid('5x3'); hs.alert.show('Grid set to 5x3'); end)
hs.hotkey.bind(mash, "6", function() hs.grid.setGrid('6x4'); hs.alert.show('Grid set to 6x4'); end)
hs.hotkey.bind(mash, "7", function() hs.grid.setGrid('7x5'); hs.alert.show('Grid set to 7x5'); end)

--- /: move window to next screen
hs.hotkey.bind(mash, "/", function() local win = getWin(); win:moveToScreen(win:screen():next()) end)

--- ,: snap window to grid
hs.hotkey.bind(mash, "m", function() hs.grid.snap(hs.window.focusedWindow()) end)

--- space: maximize window
-- hs.hotkey.bind(mash, "space", function() hs.grid.maximizeWindow() end)

--- note: hyper, "." is taken by macos sysdiagnose

--- .: minimize window
hs.hotkey.bind(mash, ".", function() hs.grid.set(getWin(), '0,0 1x1'); end)

hs.hotkey.bind(mash, "return", function() hs.grid.show() end)