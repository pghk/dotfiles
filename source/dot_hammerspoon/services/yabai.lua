--[[
    Command-line wrapper for Yabai, a tiling window manager for macOS:
    https://github.com/koekeishiya/yabai
]]

-- Absolute path may begin with /usr/local or /opt/homebrew, depending on CPU
local cmd = hs.execute("brew --prefix | tr -d '\n'", true) .. "/bin/yabai"

local yabai = function(args, opts)
  for _, v in pairs(opts) do
    table.insert(args, v)
  end
  local output, status = hs.execute(cmd .. " " .. table.concat(args, " "))
  if output ~= "" then
    print(output)
  end
  return status
end

--[[
    Executes a command as an asynchrous task, to avoid lag that can happen
    if Yabai makes a query that includes Hammerspoon itself in the results
]]
local async = function(args, opts, callback)
  local handle = function(exitCode, stdOut, stdErr)
    if stdErr ~= "" then
      print(string.format("Yabai: %s", stdErr))
    end
    if callback ~= nil then
      callback(stdOut, stdErr, exitCode)
    end
  end
  for _, v in pairs(opts) do
    table.insert(args, v)
  end
  hs.task.new(cmd, handle, args):start()
end

return {
  display = function(opts)
    return yabai({ "-m", "display" }, opts)
  end,
  space = function(opts)
    return yabai({ "-m", "space" }, opts)
  end,
  window = function(opts)
    return yabai({ "-m", "window" }, opts)
  end,
  query = function(opts, callback)
    async({ "-m", "query" }, opts, callback)
  end,
}
