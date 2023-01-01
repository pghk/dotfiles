local group = vim.api.nvim_create_augroup
local on = vim.api.nvim_create_autocmd

local main = group("main", { clear = true })

-- Highlight on yank
on("TextYankPost", {
    command = "silent! lua vim.highlight.on_yank()",
    group = main
})

-- Disable colorcolumn when not necessary 
on("FileType", {
    pattern = { "netrw", "git*" },
    command = "setlocal colorcolumn=",
    group = main
})

-- Start git commit messages in insert mode
on("FileType", {
    pattern = { "gitcommit", "gitrebase" },
    command = "startinsert | 1",
    group = main
})

