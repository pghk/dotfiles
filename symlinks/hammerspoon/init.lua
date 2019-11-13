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
