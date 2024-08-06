local window = require("services.window.grid")

--[[
    Hotkey bindings
]]

-- note: hyper + [,.] are reserved by macOS
local MEH = { "shift", "ctrl", "alt" }
local HYPER = { "shift", "ctrl", "alt", "cmd" }

-- hs.hotkey.bind(HYPER, "return", modal.cycleLayoutMode)
-- hs.hotkey.bind(MEH, "n", managed.display.focusNext)
-- hs.hotkey.bind(MEH, "m", modal.toggleWindowFloat)
hs.hotkey.bind(MEH, "space", require("services.kitty").toggle)
--
-- local tiledWindowActions = {
--   { HYPER, "m", managed.pane.super },
--
--   { HYPER, "y", managed.space.rotate },
--   { HYPER, "u", managed.space.flip },
--   { HYPER, "i", managed.pane.swap },
--   { HYPER, "o", managed.space.reset },
--
--   { MEH, "y", managed.pane.rotate },
--   { MEH, "o", managed.space.balance },
--
--   { MEH, "h", managed.pane.focusWest },
--   { MEH, "j", managed.pane.focusSouth },
--   { MEH, "k", managed.pane.focusNorth },
--   { MEH, "l", managed.pane.focusEast },
-- }
--
-- local stackedWindowActions = {
--   { MEH, "i", managed.stack.focusNext },
--   { MEH, "u", managed.stack.focusPrev },
-- }

local floatingWindowActions = {
  { HYPER, "n", window.moveToNextScreen },
  { HYPER, "m", window.maximize },

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

local function bindHotkeys(list, repeating)
  for _, v in ipairs(list) do
    if repeating then
      hs.hotkey.bind(v[1], v[2], v[3], nil, v[3])
    else
      hs.hotkey.bind(v[1], v[2], v[3])
    end
  end
end

-- bindModalHotkeys(modal.tile, tiledWindowActions)
bindHotkeys(floatingWindowActions)
bindHotkeys(floatingWindowRepeatActions, true)
-- bindModalHotkeys(modal.stack, stackedWindowActions)
