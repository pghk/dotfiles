ManagerEnabled = true

local cmd = hs.execute("brew --prefix | tr -d '\n'", true) .. "/bin/aerospace"
local aerospace = function(args)
  local output, status = hs.execute(cmd .. " " .. table.concat(args, " "))
  if output ~= "" then
    print(output)
  end
  return status
end

local module = {
  float = hs.hotkey.modal.new(),
}

module.cycleLayoutMode = function()
  if ManagerEnabled then
    aerospace({ "enable off" })
    ManagerEnabled = false
    module.float:enter()
  else
    aerospace({ "enable on" })
    ManagerEnabled = true
    module.float:exit()
  end
end

return module
