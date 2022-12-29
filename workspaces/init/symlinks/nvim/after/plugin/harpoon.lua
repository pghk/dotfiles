local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<A-=>", mark.add_file)
vim.keymap.set("n", "<A-->", ui.toggle_quick_menu)

vim.keymap.set("n", "<A-[>", ui.nav_next)
vim.keymap.set("n", "<A-]>", ui.nav_prev)

vim.keymap.set("n", "<A-1>", function() ui.nav_file(1) end)
vim.keymap.set("n", "<A-2>", function() ui.nav_file(2) end)
vim.keymap.set("n", "<A-3>", function() ui.nav_file(3) end)
vim.keymap.set("n", "<A-4>", function() ui.nav_file(4) end)
vim.keymap.set("n", "<A-5>", function() ui.nav_file(5) end)
vim.keymap.set("n", "<A-6>", function() ui.nav_file(6) end)
vim.keymap.set("n", "<A-7>", function() ui.nav_file(7) end)
vim.keymap.set("n", "<A-8>", function() ui.nav_file(8) end)
vim.keymap.set("n", "<A-9>", function() ui.nav_file(9) end)
vim.keymap.set("n", "<A-0>", function() ui.nav_file(10) end)


