-- Sequencing: shared foundation → core → plugin manager → plugins
vim.cmd("source " .. vim.fn.getenv("XDG_CONFIG_HOME") .. "/vim/vimrc.shared")

require("core.options")
require("core.keymaps")
require("core.autocmds")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  install = { missing = true },
  checker = { enabled = true, notify = false },
})
