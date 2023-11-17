local M = { pid = nil }

local function openInstance()
  os.execute("/Applications/kitty.app/Contents/MacOS/kitty \z
    --title scratchpad \z
    --directory ~ \z
    --start-as maximized \z
    --override background_opacity=0.95 \z
    --override macos_hide_from_tasks=yes \z
    --override macos_quit_when_last_window_closed=yes \z
    &")
end

-- Thanks to https://github.com/folke/dot/blob/master/hammerspoon/quake.lua
local function getInstance()
  if M.pid then
    local app = hs.application.get(M.pid)
    if app and app:isRunning() then return app end
  end

  local f = io.popen("pgrep -af scratchpad")

  if f == nil then return end
  local ret = f:read("*a")
  f:close()

  M.pid = tonumber(ret)
  return M.pid and hs.application.applicationForPID(M.pid)
end

local function ensureOnCurrentScreen (window)
  local thisScreen = hs.screen.mainScreen()
  local windowScreen = window:screen()
  if windowScreen ~= thisScreen then
    window:moveToScreen(thisScreen)
  end
end

local function ensureInCurrentSpace (window)
  local thisSpace = hs.spaces.focusedSpace()
  local windowSpaces = hs.spaces.windowSpaces(window)
  if windowSpaces then
    local spaceOfWindow = windowSpaces[1]
    if spaceOfWindow ~= thisSpace then
      hs.spaces.moveWindowToSpace(window, thisSpace)
    end
  end
end

M.toggle = function()
  local app = getInstance()

  if not app then
    openInstance()
    return
  end

  local window = app:mainWindow()

  if app:isFrontmost() then
    app:hide()
    return
  end

  ensureOnCurrentScreen(window)
  ensureInCurrentSpace(window)
  app:activate()
end

return M
