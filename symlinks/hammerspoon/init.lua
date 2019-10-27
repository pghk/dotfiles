mash = {"cmd", "alt", "ctrl", "shift"}

hs.hotkey.bind(mash, "f13", function()
  hs.reload()
  hs.notify.new(
    {
      title = "Hammerspoon",
      informativeText = "Config reloaded"
    }
  ):send()
end)
hs.loadSpoon("AClock")

hs.hotkey.bind(mash, "o", function()
  spoon.AClock:toggleShow()
end)

require "grid"
