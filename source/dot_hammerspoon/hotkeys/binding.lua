local modal = require("hotkeys.modal")
local managed = require("services.window.tiling")
local window = require("services.window.grid")

--[[
    Hotkey bindings
]]

-- note: hyper + [,.] are reserved by macOS
local MEH = { "shift", "ctrl", "alt" }
local HYPER = { "shift", "ctrl", "alt", "cmd" }

hs.hotkey.bind(HYPER, "n", modal.cycleLayoutMode)
hs.hotkey.bind(HYPER, "m", modal.toggleWindowFloat)
hs.hotkey.bind(MEH, "space", require("services.kitty").toggle)

local tiledWindowActions = {
  { MEH, "n", managed.display.focusNext },
  { MEH, "m", managed.pane.super },

  { HYPER, "y", managed.space.rotate },
  { HYPER, "u", managed.space.flip },
  { HYPER, "i", managed.pane.swap },
  { HYPER, "o", managed.space.reset },

  { MEH, "y", managed.pane.rotate },
  { MEH, "o", managed.space.balance },

  { MEH, "h", managed.pane.focusWest },
  { MEH, "j", managed.pane.focusSouth },
  { MEH, "k", managed.pane.focusNorth },
  { MEH, "l", managed.pane.focusEast },
}

local stackedWindowActions = {
  { MEH, "i", managed.stack.focusNext },
  { MEH, "u", managed.stack.focusPrev },
}

local floatingWindowActions = {
  { MEH, "n", window.moveToNextScreen },
  { MEH, "m", window.maximize },

  { MEH, "y", window.rotate },
  { MEH, "u", window.shrink },
  { MEH, "i", window.grow },
  { MEH, "o", window.center },
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

bindModalHotkeys(modal.tile, tiledWindowActions)
bindModalHotkeys(modal.float, floatingWindowActions)
bindModalHotkeys(modal.float, floatingWindowRepeatActions, true)
bindModalHotkeys(modal.stack, stackedWindowActions)
