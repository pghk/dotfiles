local modal = require("hotkeys.modal")
local managed = require("services.window.tiling")
local window = require("services.window.grid")

--[[
    Hotkey bindings
]]

-- note: hyper + [,.] are reserved by macOS
local MEH = { "shift", "ctrl", "alt" }
local HYPER = { "shift", "ctrl", "alt", "cmd" }

hs.hotkey.bind(HYPER, "return", modal.cycleLayoutMode)
hs.hotkey.bind(MEH, "space", require("services.kitty").toggle)

local tiledWindowActions = {
  { MEH, "y", managed.space.west },
  { MEH, "u", managed.window.makeTaller },
  { MEH, "i", managed.window.center },
  { MEH, "o", managed.window.makeWider },
  { MEH, "p", managed.space.east },

  { MEH, "h", managed.focus.left },
  { MEH, "j", managed.focus.down },
  { MEH, "k", managed.focus.up },
  { MEH, "l", managed.focus.right },

  -- { HYPER, "", managed.window.makeThinner },
  -- { HYPER, "", managed.window.makeTaller },
  --
  { HYPER, "m", managed.window.fullWidth },

  { HYPER, "u", managed.column.push },
  { HYPER, "i", managed.column.pop },

  { HYPER, "h", managed.window.swap_left },
  { HYPER, "j", managed.window.swap_down },
  { HYPER, "k", managed.window.swap_up },
  { HYPER, "l", managed.window.swap_right },
}

local floatingWindowActions = {
  { HYPER, "n", window.moveToNextScreen },
  { HYPER, "m", window.maximize },

  { MEH, "y", window.rotate },
  { MEH, "u", window.shrink },
  { MEH, "i", window.center },
  { MEH, "o", window.grow },
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
