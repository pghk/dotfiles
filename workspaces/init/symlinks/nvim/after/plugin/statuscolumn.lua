require("statuscol").setup()
Icons = require("pghk/ui/icons")

if _G.StatusColumn then
  return
end

local function canFold(lnum)
  local foldlevel = vim.fn.foldlevel(lnum)
  return foldlevel > 0 and foldlevel > vim.fn.foldlevel(lnum -1)
end

local function isOpen(lnum)
  return vim.fn.foldclosed(lnum) == -1
end

_G.StatusColumn = {
  handler = {
    fold = function()
      local lnum = vim.fn.getmousepos().line
      if not canFold(lnum) then
	return
      end

      local newState
      if isOpen(lnum) then
	newState = "close"
      else
	newState = "open"
      end

      vim.cmd.execute("'" .. lnum .. "fold" .. newState .. "'")
    end
  },

  display = {
    line = function()
      local relnum = tostring(vim.v.relnum)
      local lnum = tostring(vim.v.lnum)

      if relnum == "0" then
	return lnum
      end
      return relnum
    end,

    fold = function()
      if vim.v.wrap then
	return ""
      end

      local icon = " "
      local lnum = vim.v.lnum

      if canFold(lnum)  then
	if isOpen(lnum) then
	  icon = Icons.fillchars.foldopen
	else
	  icon = Icons.fillchars.foldclose
	end
      end

      return icon
    end,
  },

  sections = {
    sign_column = {
      [[%s]]
    },
    line_number = {
      [[%=%{v:lua.StatusColumn.display.line()}]]
    },
    spacing     = {
      [[ ]]
    },
    folds       = {
      [[%#FoldColumn#]],
      [[%@v:lua.StatusColumn.handler.fold@]],
      [[%{v:lua.StatusColumn.display.fold()}]]
    },
    border      = {
      [[%#StatusColumnBorder#]],
      [[│]],
    },
    padding     = {
      [[%#StatusColumnBuffer#]],
      [[ ]],
    },
  },

  build = function(tbl)
    local statuscolumn = {}

    for _, value in ipairs(tbl) do
      if type(value) == "string" then
	table.insert(statuscolumn, value)
      elseif type(value) == "table" then
	table.insert(statuscolumn, StatusColumn.build(value))
      end
    end

    return table.concat(statuscolumn)
  end,

  set_window = function(value)
    vim.defer_fn(function()
      vim.api.nvim_win_set_option(vim.api.nvim_get_current_win(), "statuscolumn", value)
    end, 1)
  end
}

vim.opt.statuscolumn = StatusColumn.build({
  StatusColumn.sections.sign_column,
  StatusColumn.sections.folds,
  StatusColumn.sections.line_number,
  StatusColumn.sections.spacing,
  StatusColumn.sections.border,
  StatusColumn.sections.padding,
})

-- local signs = { Error = "", Warn = "", Hint = "", Info = "" }
-- for type, icon in pairs(signs) do
--   local hl = "DiagnosticSign" .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = icon, numhl = hl })
-- end

local signs = { Error = "", Warn = "", Hint = "﨧", Info = "" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl })
end
