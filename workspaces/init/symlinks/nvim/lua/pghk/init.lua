require("pghk.remap")
require("pghk.set")
require("pghk.autocmd")
Icons  = require("pghk.ui.icons")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return require('lazy').setup("pghk.plugins")
