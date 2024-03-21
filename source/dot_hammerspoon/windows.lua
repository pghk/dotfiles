local M = { space = {}, pane = {}, layout = {} }

BREW_PATH = hs.execute("brew --prefix | tr -d '\n'", true)
SPACE_LAYOUTS = {}

-- Tiling window manager for macOS: https://github.com/koekeishiya/yabai
local manager = BREW_PATH .. "/bin/yabai"

-- Call yabai commands via a task instead of os.execute(), to avoid lag
local yabai = function(args)
  hs.task
    .new(manager, nil, function(_, ...)
      print("stream", hs.inspect(table.pack(...)))
      return true
    end, args)
    :start()
end

M.space.toggleLayout = function()
  local thisSpace = hs.spaces.focusedSpace()
  local next = "bsp"
  local msg = "Managed Layout"
  local sound = "Frog"
  if SPACE_LAYOUTS[thisSpace] == "bsp" then
    next = "float"
    msg = "Free Layout"
    sound = "Blow"
  end
  SPACE_LAYOUTS[thisSpace] = next
  yabai({ "-m", "space", "--layout", next })
  hs.notify
    .new(nil, {
      title = "Window Management",
      informativeText = msg,
      soundName = sound,
    })
    :send()
end

M.pane.float = function() yabai({ "-m", "window", "--toggle", "float", "--grid", "8:8:1:1:6:6" }) end

M.pane.swap = function() yabai({ "-m", "window", "--swap", "recent" }) end
M.pane.super = function() yabai({ "-m", "window", "--toggle", "zoom-parent" }) end
M.pane.rotate = function() yabai({ "-m", "window", "--toggle", "split" }) end

M.pane.focusWest = function() yabai({ "-m", "window", "--focus", "west" }) end
M.pane.focusEast = function() yabai({ "-m", "window", "--focus", "east" }) end
M.pane.focusNorth = function() yabai({ "-m", "window", "--focus", "north" }) end
M.pane.focusSouth = function() yabai({ "-m", "window", "--focus", "south" }) end

M.space.focusWest = function() yabai({ "-m", "display", "--focus", "west" }) end
M.space.focusEast = function() yabai({ "-m", "display", "--focus", "east" }) end

M.layout.balance = function() yabai({ "-m", "space", "--balance" }) end
M.layout.reset = function() yabai({ "-m", "space", "--equalize" }) end
M.layout.flip = function() yabai({ "-m", "space", "--mirror", "y-axis" }) end
M.layout.rotate = function() yabai({ "-m", "space", "--rotate", "90" }) end

local getPosition = function(relative, toScreen)
  local max = hs.grid.getGrid(toScreen) or { w = 0, h = 0 }
  return {
    x = max.w * relative.x,
    y = max.h * relative.y,
    w = max.w * (relative.w or (1 - relative.x)),
    h = max.h * (relative.h or (1 - relative.y)),
  }
end

local presets = {
  ["Microsoft Teams (work or school)"] = { x = 1 / 8, y = 0 },
  ["Mail"] = { x = 0, y = 0 },
}

M.presets = function()
  for _, window in pairs(hs.window.visibleWindows() or {}) do
    local application = window:application() or { title = "" }
    local app = application:title()
    if presets[app] ~= nil then
      local pos = getPosition(presets[app], window:screen())
      hs.grid.set(window, pos)
    end
  end
end

local cascade = function(index, count)
  local rect = { x = 0, y = 0, w = 1, h = 1 }
  if count > 1 then
    local size = 1 / (count * 0.535)
    local offset = (count - index) * ((1 - size) / (count - 1))
    rect = { x = offset, y = offset, w = size, h = size }
  end
  return rect
end

M.focus = function()
  local screens = hs.screen.allScreens() or {}
  local thisWindow = hs.window.focusedWindow()
  local others = {}
  local count = 0
  for _, v in pairs(hs.window.orderedWindows() or {}) do
    if v ~= thisWindow and v:isStandard() and v:isVisible() then
      count = count + 1
      others[count] = v
    end
  end

  for i, window in ipairs(others or {}) do
    local pos = getPosition(cascade(i, count), screens[2])
    hs.grid.set(window, pos, screens[2])
  end
end

return M
