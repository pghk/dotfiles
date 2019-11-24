mash = {"shift", "ctrl", "alt"}
hyper = {"shift", "ctrl", "alt", "cmd"}

-- setting grid of each screen based on its aspect ratio

function greatestCommonDivisor(a, b)
  while b ~= 0 do a,b = b,(a % b) end
  return a
end

function calcAspect(x, y)
  local div = greatestCommonDivisor(x, y)
  return math.floor(x / div), math.floor(y / div)
end

function smartGrid(screen)
  local mode = screen:currentMode()
  return hs.geometry(nil, nil, calcAspect(mode.w, mode.h))
end

function setSmartGrids(factor)
  for key, screen in pairs(hs.screen.allScreens()) do
    local newGrid = smartGrid(screen)
    newGrid.w = newGrid.w * factor
    newGrid.h = newGrid.h * factor
    hs.grid.setGrid(newGrid, screen)
    hs.alert.show(' ' .. newGrid.w .. ' x ' .. newGrid.h, screen)
  end
end

hs.hotkey.bind(mash, "[", function()
  setSmartGrids(1)
end)
hs.hotkey.bind(mash, "]", function()
  setSmartGrids(2)
end)
hs.hotkey.bind(mash, "\\", function()
  setSmartGrids(3)
end)

--


hs.hotkey.bind(mash, "f13", function()
  hs.reload()
  hs.notify.new(
    {
      title = "Hammerspoon",
      informativeText = "Config reloaded"
    }
  ):send()
end)

function reFrame(w, h, x, y)
  local win = hs.window.focusedWindow()
  local screen = win:screen()

  local inner = win:frame()
  local outer = screen:frame()

  inner.w = outer.w * w
  inner.h = outer.h * h
  inner.x = outer.x + ((outer.w - inner.w) / x)
  inner.y = outer.y + ((outer.h - inner.h) / y)

  return inner
end

hs.hotkey.bind(mash, "u", function ()
  hs.window.focusedWindow():setFrame(reFrame(0.57, 0.83, 4, 2))
end)

hs.hotkey.bind(mash, "o", function ()
  hs.window.focusedWindow():setFrame(reFrame(0.85, 0.833333333, 2, 2))
end)

hs.hotkey.bind(mash, ";", function ()
  hs.window.focusedWindow():setFrame(reFrame(0.4375, 0.9375, 32, 2))
end)

require "grid"
