local module = { on = false, space = {}, window = {}, column = {}, focus = {} }

-- local yabai = require("services.yabai")
local actions = PaperWM.actions

local rules = {
  { "1Password", false },
  { "IntelliJ IDEA", { allowTitles = ".* - .*" } },
  { "Messages", false },
  { "System Settings", false },
  {
    "Microsoft Teams",
    {
      allowTitles = {
        "Activity |",
        "Chat |",
        "Teams and Channels |",
        "Calendar |",
        "OneDrive |",
        "Calls |",
      },
    },
  },
}
for _, rule in ipairs(rules) do
  print(hs.inspect(rule))
  PaperWM.window_filter:setAppFilter(rule[1], rule[2])
end

-- module.display.focusNext = function()
-- local callback = function(queryResults)
--   local next = getNextDisplay(queryResults)
--   if next ~= nil then
--     yabai.display({ "--focus", tostring(next) })
--   end
-- end
-- yabai.query({ "--displays" }, callback)
-- end

module.enable = function()
  PaperWM:start()
end

module.disable = function()
  PaperWM:stop()
end

module.space.tile = function()
  PaperWM:tileSpace(hs.spaces.focusedSpace())
end

module.window.center = actions.center_window
module.window.fullWidth = actions.full_width

module.window.makeWider = actions.cycle_width
module.window.makeTaller = actions.cycle_height
module.window.makeThinner = actions.reverse_cycle_width
module.window.makeShorter = actions.reverse_cycle_height

module.column.push = actions.slurp_in
module.column.pop = actions.barf_out
module.space.west = actions.switch_space_l
module.space.east = actions.switch_space_r

module.window.swap_left = actions.swap_left
module.window.swap_right = actions.swap_right
module.window.swap_up = actions.swap_up
module.window.swap_down = actions.swap_down

local handleFocus = function(action)
  local newFocus = action()
  if newFocus == nil then
    return
  end
  hs.timer.doAfter(hs.window.animationDuration, function()
    local destFrame = newFocus:frame()
    local newX = destFrame.x + (destFrame.w * 0.618)
    local newY = destFrame.y + 12
    hs.mouse.absolutePosition({ x = newX, y = newY })
  end)
end

module.focus.left = function()
  handleFocus(actions.focus_left)
end
module.focus.right = function()
  handleFocus(actions.focus_right)
end
module.focus.up = function()
  handleFocus(actions.focus_up)
end
module.focus.down = function()
  handleFocus(actions.focus_down)
end

return module
