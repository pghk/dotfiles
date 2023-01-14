local function setPosition (window)
  window:moveToScreen(hs.screen.mainScreen())
  local function newSize(cell)
    cell.w = 8
    cell.h = 1
  end
  hs.grid.adjustWindow(newSize, hs.window.focusedWindow())
end

local function openWindow (app)
  app:selectMenuItem({"Shell", "New OS Window"})
  app:activate()
  local window = app:focusedWindow()
  setPosition(window)
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

local function toggle()
  local app = hs.application.get("kitty")

  if not app then
    hs.application.launchOrFocus("kitty")
    app = hs.application.get("kitty")
    openWindow(app)
    return
  end

  local window = app:mainWindow()
  if not window then
    openWindow(app)
    return
  end

  if app:isFrontmost() then
    app:hide()
    return
  end

  ensureOnCurrentScreen(window)
  ensureInCurrentSpace(window)
  app:activate()
end

return { toggle = toggle }
