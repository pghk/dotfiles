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



hs.hotkey.bind(mash, "u", function ()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.w = 4 * (max.w / 7)
  f.h = 5 * (max.h / 6)
  f.x = max.x + ((max.w - f.w) / 4)
  f.y = max.y + ((max.h - f.h) / 2)

  win:setFrame(f)
end)

hs.hotkey.bind(mash, "o", function ()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.w = 6 * (max.w / 7)
  f.h = 5 * (max.h / 6)
  f.x = max.x + ((max.w - f.w) / 2)
  f.y = max.y + ((max.h - f.h) / 2)

  win:setFrame(f)
end)

require "grid"
