local modal = require("hotkeys.modal")
local tiling = require("services.window.tiling")
local window = require("services.window.grid")

local function bindHotkeys(list)
  for _, v in ipairs(list) do
    hs.hotkey.bind(v[1], v[2], v[3])
  end
end

local function bindModalHotkeys(mode, list, repeating)
  for _, v in ipairs(list) do
    if repeating then
      mode:bind(v[1], v[2], v[3], nil, v[3])
    else
      mode:bind(v[1], v[2], v[3])
    end
  end
end

--[[
    Hotkey bindings
]]

-- note: hyper + [,.] are reserved by macOS
local MEH = { "shift", "ctrl", "alt" }
local HYPER = { "shift", "ctrl", "alt", "cmd" }

-- bound elsewhere
-- { MEH, "u", space left },
-- { MEH, "o", space right },
--
local actions = {
  { { "alt", "shift" }, "space", modal.cycleHotkeyMode },

  { MEH, "0", window.shrink },
  { MEH, "-", window.grow },

  { MEH, "i", window.center },
  { HYPER, "i", window.maximize },
  { HYPER, "u", window.rotate },

  { HYPER, "h", tiling.actions.pushWindow },
  { HYPER, "j", tiling.actions.pullWindow },
  { HYPER, "k", tiling.actions.swapWindows },
  { HYPER, "l", tiling.actions.mouseNextScreen },

  { MEH, "h", tiling.actions.focusWest },
  { MEH, "j", tiling.actions.focusSouth },
  { MEH, "k", tiling.actions.focusNorth },
  { MEH, "l", tiling.actions.focusEast },
}

local modalActions = {
  { MEH, "h", window.moveLeft },
  { MEH, "j", window.moveDown },
  { MEH, "k", window.moveUp },
  { MEH, "l", window.moveRight },

  { HYPER, "h", window.makeThinner },
  { HYPER, "j", window.makeTaller },
  { HYPER, "k", window.makeShorter },
  { HYPER, "l", window.makeWider },
}

bindHotkeys(actions)
bindModalHotkeys(modal.modes.move, modalActions, true)
