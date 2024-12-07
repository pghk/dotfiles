local module = { on = false }

local cmd = hs.execute("brew --prefix | tr -d '\n'", true) .. "/bin/aerospace"
local aerospace = function(args)
  local output, status = hs.execute(cmd .. " " .. table.concat(args, " "))
  if output ~= "" then
    print(output)
  end
  return status
end

module.enable = function()
  if module.on then
    aerospace({ "enable off" })
    module.on = false
  else
    aerospace({ "enable on" })
    module.on = true
  end
end

module.toggleWindowLayout = function()
  aerospace({ "layout tiling floating" })
end

return module
