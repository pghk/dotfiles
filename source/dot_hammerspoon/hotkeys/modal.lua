---@class hs.menubar
HotkeyModeIndicator = hs.menubar.new()
HotkeyModeIndicator:setTooltip("Hotkey mode")

local M = {
  mode = "move",
  modes = {
    move = hs.hotkey.modal.new():enter(),
    focus = hs.hotkey.modal.new(),
  },
}

local icons = {
  move = 0x1014A0,
  focus = 0x1029EE,
}

local setIcon = function(code)
  local char = utf8.char(code)
  local title = hs.styledtext.new(char, { font = { name = "SF Pro", size = 14 } })
  HotkeyModeIndicator:setTitle(title)
end

M.modes.move:enter()

M.cycleHotkeyMode = function()
  if M.mode == "move" then
    M.mode = "focus"
    M.modes.move:exit()
    M.modes.focus:enter()
  else
    M.mode = "move"
    M.modes.focus:exit()
    M.modes.move:enter()
  end
end

function M.modes.move:entered()
  setIcon(icons.move)
end

function M.modes.move:exited()
  setIcon(icons.focus)
end

return M
