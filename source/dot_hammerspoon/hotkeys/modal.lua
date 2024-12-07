HotkeyModeTiled = true
HotkeyModeIndicator = hs.menubar.new()
ManagerEnabled = true

local module = {
  float = hs.hotkey.modal.new(),
}

local icons = {
  float = 0x1014A0,
  tile = 0x1029EE,
}

local setIcon = function(code)
  local char = utf8.char(code)
  local title = hs.styledtext.new(char, { font = { name = "SF Pro", size = 14 } })
  HotkeyModeIndicator:setTitle(title)
end

setIcon(icons.tile)

module.cycleHotkeyMode = function()
  if HotkeyModeTiled then
    module.float:enter()
  else
    module.float:exit()
  end
end

function module.float:entered()
  HotkeyModeTiled = false
  setIcon(icons.float)
end

function module.float:exited()
  HotkeyModeTiled = true
  setIcon(icons.tile)
end

-- print(hs.inspect({ window:title(), app, event }))

return module
