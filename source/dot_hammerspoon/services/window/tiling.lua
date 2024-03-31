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
      yabai({ "-m", "display", "--focus", tostring(next) })
    end
  end
  yabai({ "-m", "query", "--displays" }, callback)
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
  yabai({ "-m", "query", "--spaces", "--space" }, process)
end

module.space.cycleLayout = function(current, callback)
  local options = { "bsp", "float", "stack" }
  local next = getNextOptionInCycle(options, current)

  yabai({ "-m", "space", "--layout", next })
  callback(next)

  local msg = {
    title = "Window Management",
    subtitle = "Changed layout",
    informativeText = nil,
    soundName = nil,
  }
  if next == "float" then
    msg.title = "Floating space"
    msg.soundName = "Glass"
  end
  if next == "bsp" then
    msg.title = "Managed space"
    msg.informativeText = "Binary space partitioning"
    msg.soundName = "Frog"
  end
  if next == "stack" then
    msg.title = "Managed space"
    msg.informativeText = "Stacked windows"
    msg.soundName = "Hero"
  end
  local notification = hs.notify.new(msg)
  if notification then
    notification:send()
  end
end

module.space.balance = function() yabai({ "-m", "space", "--balance" }) end
module.space.reset = function() yabai({ "-m", "space", "--equalize" }) end
module.space.flip = function() yabai({ "-m", "space", "--mirror", "y-axis" }) end
module.space.rotate = function() yabai({ "-m", "space", "--rotate", "270" }) end

module.stack.focusNext = function()
  local callback = function(_, _, code)
    if code == 1 then
      yabai({ "-m", "window", "--focus", "stack.first" })
    end
  end
  yabai({ "-m", "window", "--focus", "stack.next" }, callback)
end

module.stack.focusPrev = function()
  local callback = function(_, _, code)
    if code == 1 then
      yabai({ "-m", "window", "--focus", "stack.last" })
    end
  end
  yabai({ "-m", "window", "--focus", "stack.prev" }, callback)
end

module.pane.swap = function() yabai({ "-m", "window", "--swap", "recent" }) end
module.pane.super = function() yabai({ "-m", "window", "--toggle", "zoom-parent" }) end
module.pane.rotate = function() yabai({ "-m", "window", "--toggle", "split" }) end

module.pane.focusWest = function() yabai({ "-m", "window", "--focus", "west" }) end
module.pane.focusEast = function() yabai({ "-m", "window", "--focus", "east" }) end
module.pane.focusNorth = function() yabai({ "-m", "window", "--focus", "north" }) end
module.pane.focusSouth = function() yabai({ "-m", "window", "--focus", "south" }) end

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
  yabai({ "-m", "query", "--windows", "--window" }, process)
end

module.window.toggleFloat = function(currentlyFloating, callback)
  local cmd = { "-m", "window", "--toggle", "float" }
  if not currentlyFloating then
    table.insert(cmd, "--grid")
    table.insert(cmd, "8:8:1:1:6:6")
  end
  yabai(cmd, callback)
end

return module
