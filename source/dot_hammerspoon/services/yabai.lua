--[[
    Command-line wrapper for Yabai, a tiling window manager for macOS:
    https://github.com/koekeishiya/yabai
    
    Executes the commands as an asynchrous task, to avoid lag that can happen
    if Yabai makes a query that includes Hammerspoon itself in the results
]]

-- Absolute path may begin with /usr/local or /opt/homebrew, depending on CPU
local cmd = hs.execute("brew --prefix | tr -d '\n'", true) .. "/bin/yabai"

return function(args, callback)
  local handle = function(exitCode, stdOut, stdErr)
    if stdErr ~= "" then
      print(string.format("Yabai: %s", stdErr))
    end
    if callback ~= nil then
      callback(stdOut, stdErr, exitCode)
    end
  end
  hs.task.new(cmd, handle, args):start()
end
