require("hs.ipc")

local managed = require("services.window.tiling")

Context = {
  space = "float",
  window = { floating = true, stacked = false },
}

local module = {
  float = hs.hotkey.modal.new(),
  tile = hs.hotkey.modal.new(),
  stack = hs.hotkey.modal.new(),
}

local handleChange = function()
  if Context.space == "float" or Context.window.floating then
    module.float:enter()
  else
    module.float:exit()
  end
  if Context.space == "bsp" and not Context.window.floating then
    module.tile:enter()
  end
  if Context.space == "stack" or Context.window.stacked then
    module.stack:enter()
  end
end

module.setWindowState = function()
  local callback = function(windowState)
    Context.window = windowState
    handleChange()
  end
  managed.window.getState(callback)
end

module.setSpaceState = function()
  local callback = function(spaceState)
    Context.space = spaceState
    handleChange()
  end
  managed.space.getState(callback)
end

-- Initalize
module.setWindowState()
module.setSpaceState()

function HandleYabaiWindow(data)
  -- local window = hs.json.decode(data) or {}
  -- print(hs.inspect(data))
  module.setWindowState()
end

SpaceWatcher = hs.spaces.watcher.new(function()
  module.setSpaceState()
end)
SpaceWatcher:start()

function HandleYabaiSpace(data)
  -- local space = hs.json.decode(data) or {}
  print(hs.inspect(data))
end

-- When triggering operations that our watchers wouldn't see, have the window
-- manager call us back, so we can update state manually
module.cycleLayoutMode = function()
  local callback = function(layoutName)
    Context.space = layoutName
    module.setWindowState()
  end
  managed.space.cycleLayout(Context.space, callback)
end

module.toggleWindowFloat = function()
  local callback = function()
    module.setWindowState()
  end
  managed.window.toggleFloat(Context.window.floating, callback)
end

return module
