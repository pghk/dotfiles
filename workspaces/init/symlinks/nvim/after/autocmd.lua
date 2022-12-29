local api = vim.api

-- Highlight on yank
local yankGrp = api.nvim_create_augroup("YankHighlight", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
  command = "silent! lua vim.highlight.on_yank()",
  group = yankGrp,
})


-- Disable colorcolumn in NetRW
api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  command = "set colorcolumn=",
})


