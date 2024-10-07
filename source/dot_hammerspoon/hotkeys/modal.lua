require("hs.ipc")
utf8 = require("utf8")

local managed = require("services.window.tiling")

HotkeyModeIndicator = hs.menubar.new()

ManagerEnabled = false
WindowManaged = false

local updateIcon = function()
  local char = utf8.char(0x10088C)
  if WindowManaged then
    char = utf8.char(0x101EFB)
  end
  local title = hs.styledtext.new(char, { font = { name = "SF Pro", size = 14 } })
  HotkeyModeIndicator:setTitle(title)
end

local module = {
  float = hs.hotkey.modal.new(),
  tile = hs.hotkey.modal.new(),
}

local handleChange = function(window)
  WindowManaged = PaperWM.window_filter:pause():isWindowAllowed(window)
  PaperWM.window_filter:resume()
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
