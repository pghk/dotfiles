Icons = require("pghk/ui/icons")
return {
    'mfussenegger/nvim-dap',
    "rouge8/neotest-rust",
    {
        "nvim-neotest/neotest",
        config = function()
            local neotest = require('neotest')
            neotest.setup({
                adapters = {
                    require("neotest-rust"),
                },
                icons = {
                    child_indent = "│",
                    child_prefix = "├",
                    collapsed = "─",
                    expanded = "╮",
                    failed = Icons.test.fail,
                    final_child_indent = " ",
                    final_child_prefix = "╰",
                    non_collapsible = "─",
                    passed = Icons.test.pass,
                    running = "",
                    running_animated = { "", "", "", "", "", "", ""},
                    skipped = "",
                    unknown = ""
                },
                output_panel = {
                    enabled = true,
                    open = "botright split | resize 15"
                },
                projects = {},
                quickfix = {
                    enabled = true,
                    open = true
                },
                run = {
                    enabled = true
                },
                running = {
                    concurrent = true
                },
                status = {
                    enabled = true,
                    signs = true,
                    virtual_text = false
                },
                strategies = {
                    integrated = {
                        height = 40,
                        width = 120
                    }
                },
                summary = {
                    animated = true,
                    enabled = true,
                    expand_errors = true,
                    follow = true,
                    mappings = {
                        attach = "a",
                        clear_marked = "M",
                        clear_target = "T",
                        debug = "d",
                        debug_marked = "D",
                        expand = { "<CR>", "<2-LeftMouse>" },
                        expand_all = "e",
                        jumpto = "i",
                        mark = "m",
                        next_failed = "J",
                        output = "o",
                        prev_failed = "K",
                        run = "r",
                        run_marked = "R",
                        short = "O",
                        stop = "u",
                        target = "t"
                    },
                    open = "botright vsplit | vertical resize 50"
                }
            })
            vim.keymap.set('n', '<leader>tr', neotest.run.run, { desc = "[T]est: [R]un nearest test" })
            vim.keymap.set('n', '<leader>tl', neotest.run.run_last, { desc = "[T]est: Run [L]ast test" })
            vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand("%")) end,
                { desc = "[T]est: run current [F]ile" })
            vim.keymap.set('n', '<leader>ts', neotest.summary.toggle,
                { desc = "[T]est: Toggle [S]ummary window" })
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim"
        }
    },
}
