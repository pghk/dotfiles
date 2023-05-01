-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local group = vim.api.nvim_create_augroup
local on = vim.api.nvim_create_autocmd

local main = group("main", { clear = true })

-- Permit wrapping sometimes
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
