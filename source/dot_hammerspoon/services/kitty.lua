local M = {}

local visor_pid
local name = "Terminal Visor"

local function openInstance()
  os.execute("/Applications/kitty.app/Contents/MacOS/kitty \z
    --title '" .. name .. "' --directory ~ \z
    --start-as maximized \z
    --override background_opacity=0.95 \z
    --override macos_hide_from_tasks=yes \z
    --override macos_quit_when_last_window_closed=yes \z
    &")
end

-- Thanks to https://github.com/folke/dot/blob/master/hammerspoon/quake.lua
local function getInstance()
  if visor_pid then
    local app = hs.application(visor_pid)
    if app and app:isRunning() then
      return app
    end
  end

  local f = io.popen("pgrep -af " .. name)

  if f == nil then
    return
  end
  local ret = f:read("*a")
  f:close()

  visor_pid = tonumber(ret)
  print(visor_pid)
  if not visor_pid then
    return
  end
  return hs.application.applicationForPID(visor_pid)
end

local function ensureOnCurrentScreen(window)
  if not window then
    return
  end
  local thisScreen = hs.screen.mainScreen()
  local windowScreen = window:screen()
  if windowScreen ~= thisScreen then
    window:moveToScreen(thisScreen)
  end
end

local function ensureInCurrentSpace(window)
  if not window then
    return
  end
  local thisSpace = hs.spaces.focusedSpace()
  local windowSpaces = hs.spaces.windowSpaces(window)
  if windowSpaces then
    local spaceOfWindow = windowSpaces[1]
    if spaceOfWindow ~= thisSpace then
      hs.spaces.moveWindowToSpace(window, thisSpace)
    end
  end
end

local moveToVisor = function(window)
  if not window then
    return
  end
  local max = hs.grid.getGrid(window:screen())
  if not max then
    return
  end
  hs.grid.set(window, { x = 0, y = 0, w = max.w, h = max.h * 0.33 })
end

M.toggle = function()
  local app = getInstance()

  if not app then
    openInstance()
    return
  end

  local window = app:mainWindow()

  if window:isVisible() and app:isFrontmost() then
    app:hide()
    return
  end

  ensureOnCurrentScreen(window)
  ensureInCurrentSpace(window)
  moveToVisor(window)
  app:activate()
end

return M
