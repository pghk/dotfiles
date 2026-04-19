-- Neovim-specific options that extend vimrc.shared.
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
opt.foldlevel = 99
opt.foldlevelstart = 99
