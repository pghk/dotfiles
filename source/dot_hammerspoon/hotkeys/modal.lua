require("hs.ipc")
utf8 = require("utf8")

local managed = require("services.window.tiling")

HotkeyModeIndicator = hs.menubar.new()

ManagerEnabled = false
WindowManaged = false
local icons = {
  float = 0x10088C,
  tile = 0x101EFB,
}

local setIcon = function(code)
  local char = utf8.char(code)
  local title = hs.styledtext.new(char, { font = { name = "SF Pro", size = 14 } })
  HotkeyModeIndicator:setTitle(title)
end

local module = {
  float = hs.hotkey.modal.new(),
  tile = hs.hotkey.modal.new(),
}

function module.float:entered()
  setIcon(icons.float)
end
function module.tile:entered()
  setIcon(icons.tile)
end

local handleChange = function(provided)
  PaperWM.window_filter:pause()
  local window = provided or hs.window.focusedWindow()
  WindowManaged = PaperWM.window_filter:isWindowAllowed(window)
  if ManagerEnabled and WindowManaged then
    module.tile:enter()
    module.float:exit()
    setIcon(icons.tile)
  else
    module.float:enter()
    module.tile:exit()
    setIcon(icons.float)
  end
  PaperWM.window_filter:resume()
end

WindowWatcher = hs.window.filter.new()
WindowWatcher:subscribe({ "windowFocused", "windowUnhidden" }, handleChange)
AppWatcher = hs.application.watcher.new(function(appName, event, app)
  if appName == "kitty" and event == hs.application.watcher.activated then
    handleChange(app:mainWindow())
  end
end)
AppWatcher:start()

module.cycleLayoutMode = function()
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
