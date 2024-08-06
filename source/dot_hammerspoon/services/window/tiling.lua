local module = { display = {}, space = {}, stack = {}, pane = {}, window = {} }

local yabai = require("services.yabai")

local getNextOptionInCycle = function(options, current)
  local next
  for k, v in pairs(options) do
    if v == current then
      next = #options + (k % #options) - (#options - 1)
    end
  end
  return options[next]
end

local getNextDisplay = function(displayJson)
  local data = hs.json.decode(displayJson)
  local options = {}
  local current
  for k, v in pairs(data or {}) do
    options[k] = v.index
    if v["has-focus"] then
      current = v.index
    end
  end
  return getNextOptionInCycle(options, current)
end

module.display.focusNext = function()
  local callback = function(queryResults)
    local next = getNextDisplay(queryResults)
    if next ~= nil then
      yabai.display({ "--focus", tostring(next) })
    end
  end
  yabai.query({ "--displays" }, callback)
end

module.space.getState = function(callback)
  local process = function(queryResults)
    local space = hs.json.decode(queryResults)
    local state = "float"
    if space ~= nil then
      state = space["type"]
    end
    callback(state)
  end
  yabai.query({ "--spaces", "--space" }, process)
end

module.space.cycleLayout = function(current, callback)
  local options = { "bsp", "float", "stack" }
  local next = getNextOptionInCycle(options, current)

  yabai.space({ "--layout", next })
  callback(next)

  -- local msg = {
  --   title = "Window Management",
  --   subtitle = "Changed layout",
  --   informativeText = nil,
  --   soundName = nil,
  -- }
  -- if next == "float" then
  --   msg.title = "Floating space"
  --   msg.soundName = "Glass"
  -- end
  -- if next == "bsp" then
  --   msg.title = "Managed space"
  --   msg.informativeText = "Binary space partitioning"
  --   msg.soundName = "Frog"
  -- end
  -- if next == "stack" then
  --   msg.title = "Managed space"
  --   msg.informativeText = "Stacked windows"
  --   msg.soundName = "Hero"
  -- end
  -- local notification = hs.notify.new(msg)
  -- if notification then
  --   notification:send()
  -- end
end

module.space.balance = function()
  yabai.space({ "--balance" })
end
module.space.reset = function()
  yabai.space({ "--equalize" })
end
module.space.flip = function()
  yabai.space({ "--mirror", "y-axis" })
end
module.space.rotate = function()
  yabai.space({ "--rotate", "270" })
end

module.stack.focusNext = function()
  if not yabai.window({ "--focus", "stack.next" }) then
    yabai.window({ "--focus", "stack.first" })
  end
end

module.stack.focusPrev = function()
  if not yabai.window({ "--focus", "stack.prev" }) then
    yabai.window({ "--focus", "stack.last" })
  end
end

module.pane.swap = function()
  yabai.window({ "--swap", "recent" })
end
module.pane.super = function()
  yabai.window({ "--toggle", "zoom-parent" })
end
module.pane.rotate = function()
  yabai.window({ "--toggle", "split" })
end

module.pane.focusWest = function()
  yabai.window({ "--focus", "west" })
end
module.pane.focusEast = function()
  yabai.window({ "--focus", "east" })
end
module.pane.focusNorth = function()
  yabai.window({ "--focus", "north" })
end
module.pane.focusSouth = function()
  yabai.window({ "--focus", "south" })
end

module.window.getState = function(callback)
  local process = function(queryResults)
    local window
    if queryResults ~= "" then
      window = hs.json.decode(queryResults)
    end
    local state = { floating = true, stacked = false }
    if window ~= nil then
      state.floating = window["is-floating"]
      state.stacked = window["stack-index"] > 0
    end
    callback(state)
  end
  yabai.query({ "--windows", "--window" }, process)
end

module.window.toggleFloat = function(currentlyFloating, callback)
  local args = { "--toggle", "float" }
  if not currentlyFloating then
    table.insert(args, "--grid")
    table.insert(args, "8:8:1:1:6:6")
  end
  yabai.window(args)
  callback()
end

return module
