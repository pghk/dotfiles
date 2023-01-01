local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-rust")
  }
})

-- Run the nearest test 
vim.keymap.set("n", "<leader>tr", neotest.run.run)
-- Run the last test 
vim.keymap.set("n", "<leader>tl", neotest.run.run_last)
-- Debug the last test 
vim.keymap.set("n", "<leader>td", function()
  neotest.run.run({ strategy = "dap" })
end)

-- Run the current file
vim.keymap.set("n", "<leader>tf", function()
  neotest.run.run(vim.fn.expand("%"))
end)
-- Stop the nearest test
vim.keymap.set("n", "<leader>tt", neotest.run.stop)

-- Show test summary 
vim.keymap.set("n", "<leader>ts", neotest.summary.toggle)
-- Show test output
vim.keymap.set("n", "<leader>to", neotest.output_panel.toggle)

-- Attach to the nearest test 
vim.keymap.set("n", "<leader>ta", neotest.run.attach)


