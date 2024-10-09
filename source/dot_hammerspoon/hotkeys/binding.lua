local modal = require("hotkeys.modal")
local window = require("services.window.grid")

--[[
    Hotkey bindings
]]

-- note: hyper + [,.] are reserved by macOS
local MEH = { "shift", "ctrl", "alt" }
local HYPER = { "shift", "ctrl", "alt", "cmd" }

hs.hotkey.bind(HYPER, "p", modal.cycleLayoutMode)
hs.hotkey.bind(MEH, "space", require("services.kitty").toggle)

local floatingWindowActions = {
  { MEH, "y", window.rotate },
  { MEH, "u", window.shrink },
  { MEH, "i", window.maximize },
  { MEH, "o", window.grow },

  { HYPER, "u", window.moveToNextScreen },
  { HYPER, "i", window.center },
  { HYPER, "o", window.moveToNextSpace },
}

local floatingWindowRepeatActions = {
  { MEH, "h", window.moveLeft },
  { MEH, "j", window.moveDown },
  { MEH, "k", window.moveUp },
  { MEH, "l", window.moveRight },

  { HYPER, "h", window.makeThinner },
  { HYPER, "j", window.makeTaller },
  { HYPER, "k", window.makeShorter },
  { HYPER, "l", window.makeWider },
}

local function bindModalHotkeys(mode, list, repeating)
  for _, v in ipairs(list) do
    if repeating then
      mode:bind(v[1], v[2], v[3], nil, v[3])
    else
      mode:bind(v[1], v[2], v[3])
    end
  end
end

bindModalHotkeys(modal.float, floatingWindowActions)
bindModalHotkeys(modal.float, floatingWindowRepeatActions, true)
