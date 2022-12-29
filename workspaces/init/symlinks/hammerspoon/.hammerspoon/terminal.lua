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

local function toggle()
  local app = hs.application.get("kitty")

  if not app then
    hs.application.launchOrFocus("kitty")
    app = hs.application.get("kitty")
    openWindow(app)
    return
  end

  if not app:mainWindow() then
    openWindow(app)
    return
  end

  if app:isFrontmost() then
    app:hide()
    return
  end

  if app:isHidden() then
    app:activate()
    return
  end
end

return { toggle = toggle }
