-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- Mirror of ~/.config/vim/vimrc.shared — update that file first, then sync here

-- Move highlighted lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Delete / replace without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Tab navigation
vim.keymap.set("n", "<S-l>", ":tabnext<CR>")
vim.keymap.set("n", "<S-h>", ":tabprev<CR>")
