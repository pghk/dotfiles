-- Neovim-specific autocommands that extend vimrc.shared.
local group = vim.api.nvim_create_augroup
local on = vim.api.nvim_create_autocmd

local main = group("main", { clear = true })

-- Permit wrapping in prose files
on("FileType", {
  pattern = { "markdown" },
  command = "setlocal wrap linebreak",
  group = main,
})

-- Start git commit messages in insert mode
on("FileType", {
  pattern = { "gitcommit", "gitrebase" },
  command = "startinsert | 1",
  group = main,
})

-- Chezmoi template filetypes
on({ "BufRead", "BufNewFile" }, {
  pattern = { "*.sh.tmpl", "*Brewfile.tmpl", "*Brewfile" },
  command = "set filetype=bash",
  group = main,
})

on({ "BufRead", "BufNewFile" }, {
  pattern = "*.toml.tmpl",
  command = "set filetype=toml",
  group = main,
})

on({ "BufRead", "BufNewFile" }, {
  pattern = ".chezmoiignore",
  command = "set filetype=gitignore",
  group = main,
})
