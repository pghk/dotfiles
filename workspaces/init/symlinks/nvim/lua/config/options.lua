-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  foldsep = " ",
}
opt.list = false
opt.listchars = {
  tab = " ",
  space = "·",
  trail = "•",
  extends = "❯",
  precedes = "❮",
  nbsp = "␣",
}

opt.foldcolumn = "1"
