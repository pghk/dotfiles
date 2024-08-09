require("hs.ipc")

local managed = require("services.window.tiling")

HotkeyModeIndicator = hs.menubar.new()

ManagerEnabled = false
WindowManaged = false

local updateIcon = function(floating)
  local text = "󰉧 "
  if WindowManaged then
    text = "󱒇 "
  end
  HotkeyModeIndicator:setTitle(text)
end

local module = {
  float = hs.hotkey.modal.new(),
  tile = hs.hotkey.modal.new(),
}

local handleChange = function(window)
  if WindowManaged then
    module.tile:enter()
    module.float:exit()
    updateIcon()
  else
    module.float:enter()
    module.tile:exit()
    updateIcon()
  end
end

WindowWatcher = hs.window.filter.new()
WindowWatcher:subscribe("windowFocused", handleChange)

module.cycleLayoutMode = function()
  local window = hs.window.focusedWindow()
  if not ManagerEnabled then
    WindowManaged = PaperWM.window_filter:isWindowAllowed(window)
    managed.enable()
    ManagerEnabled = true
  else
    managed.disable()
    ManagerEnabled = false
    WindowManaged = false
  end
  handleChange(hs.window.focusedWindow())
end

return module
