hs.logger.defaultLogLevel = 'info'
title_bar_height = 23

mash = {"shift", "ctrl", "alt"}
hyper = {"shift", "ctrl", "alt", "cmd"}

hs.hotkey.bind(mash, "f13", function()
  hs.reload()
  hs.notify.new(
    {
      title = "Hammerspoon",
      informativeText = "Config reloaded"
    }
  ):send()
end)

function getWin()
  return hs.window.focusedWindow()
end

hs.window.animationDuration = 0.1

require "grid"

-- setting grid of each screen based on its aspect ratio
default_margins = "8,8"
hs.grid.setMargins(default_margins)
setAllGrids(1)

hs.hotkey.bind(mash, "[", function()
  setAllGrids(1)
end)
hs.hotkey.bind(mash, "]", function()
  setAllGrids(2)
end)
hs.hotkey.bind(mash, "\\", function()
  setAllGrids(.5)
end)

--

hs.hotkey.bind(mash, "a", function ()
  local new_size = {w=4, h=3}
  local new_grid = {x=8, y=5}
  local margins = {w=(240/8), h=0}
  local position = {x=1, y=1}
  getWin():setFrame(reFrame(new_size, new_grid, margins, position))
end)






