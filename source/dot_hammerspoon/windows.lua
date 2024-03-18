local M = {}

-- Tiling window manager for macOS: https://github.com/koekeishiya/yabai
local manager = "/opt/homebrew/bin/yabai"

-- Call yabai commands via a task instead of os.execute(), to avoid lag
local yabai = function(args)
  hs.task
    .new(manager, nil, function(_, ...)
      print("stream", hs.inspect(table.pack(...)))
      return true
    end, args)
    :start()
end

M.test = function() yabai({ "-m", "window", "--swap", "recent" }) end
-- M.test = function() yabai({ "-m", "window", "--toggle", "zoom-parent" }) end
-- M.test = function() yabai({ "-m", "window", "--toggle", "split" }) end
-- M.test = function() yabai({ "-m", "display", "--focus", "west" }) end
-- M.test = function() yabai({ "-m", "window", "--focus", "west" }) end
-- M.test = function() yabai({ "-m", "space", "--balance" }) end
-- M.test = function() yabai({ "-m", "space", "--equalize" }) end
-- M.test = function() yabai({ "-m", "window", "--toggle", "float", "--grid", "8:8:1:1:6:6" }) end
-- M.test = function() yabai({ "-m", "space", "--mirror", "y-axis" }) end
-- M.test = function() yabai({ "-m", "space", "--rotate", "90" }) end
-- M.test = function() yabai({ "-m", "space", "--toggle", "gap" }) end
-- M.test = function() yabai({ "-m", "window", "--focus", "east" }) end

local resize = function(relative, screen)
  local max = hs.grid.getGrid(screen) or { w = 0, h = 0 }
  return {
    x = max.w * relative.x,
    y = max.h * relative.y,
    w = max.w * (relative.w or (1 - relative.x)),
    h = max.h * (relative.h or (1 - relative.y)),
  }
end

local function moveAndSize(window, screen, spec) hs.grid.set(window, resize(spec, screen), screen) end

local presets = {
  ["Microsoft Teams (work or school)"] = { x = 1 / 8, y = 0 },
  ["Mail"] = { x = 0, y = 0 },
}

M.presets = function()
  for _, window in pairs(hs.window.visibleWindows() or {}) do
    local application = window:application() or { title = "" }
    local app = application:title()
    if presets[app] ~= nil then
      local new = resize(presets[app], window:screen())
      hs.grid.set(window, new)
    end
  end
end

M.focus = function()
  local screens = hs.screen.allScreens() or {}
  local window = hs.window.focusedWindow()
  local others = {}
  local count = 0
  for _, v in pairs(hs.window.orderedWindows() or {}) do
    if v ~= window and v:isStandard() and v:isVisible() then
      count = count + 1
      others[count] = v
    end
  end

  moveAndSize(window, screens[1], { x = 0, y = 0, w = 1, h = 1 })

  for i, v in ipairs(others or {}) do
    local new = { x = 0, y = 0, w = 1, h = 1 }
    if count > 1 then
      local size = 1 / (count * 0.535)
      local offset = (count - i) * ((1 - size) / (count - 1))
      new = { x = offset, y = offset, w = size, h = size }
    end
    moveAndSize(v, screens[2], new)
  end
end

return M
