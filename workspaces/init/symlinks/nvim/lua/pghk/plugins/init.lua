return {
    { -- Fuzzy finder
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    { -- Fuzzy Finder Algorithm 
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable 'make' == 1
    },
    'nvim-lualine/lualine.nvim', -- Fancier statusline
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup({
                signcolumn = false,
                numhl = true
            })
        end
    },
    { -- Color theme
        'marko-cerovac/material.nvim',
        config = function ()
            require('material').setup({
                plugins = {
                    "gitsigns",
                    "nvim-cmp",
                    "telescope",
                },
                lualine_style = 'default',
                custom_colors = function(colors)
                    colors.git.modified = colors.main.yellow
                end,
                custom_highlights = {
                    FoldColumn = { link = "LineNr"},
                }
            })
            vim.g.material_style = "oceanic"
            vim.cmd('colorscheme material')
            local color = vim.api.nvim_get_hl_by_name('DiffChange', true)
            vim.api.nvim_set_hl(0, 'Folded', {
                fg = color.foreground,
                italic = true
            })
            vim.api.nvim_set_hl(0, '@text', { link = 'Normal' })
            vim.api.nvim_set_hl(0, '@error', { link = 'Error' })
        end
    },
    { -- Syntax awareness
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        }
    },
    'nvim-treesitter/playground',
    'theprimeagen/harpoon', -- Quick navigation between files
    'mbbill/undotree', -- Undo history vizualizer
    'tpope/vim-fugitive', -- Git integration
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    { -- "gc" to comment visual regions/lines
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    },
    { -- Add/change/delete surrounding delimiter pairs
        "kylechui/nvim-surround",
        version="1.*",
        config = function()
            require("nvim-surround").setup({ })
        end
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim"
        }
    },
    "rouge8/neotest-rust",
    'mfussenegger/nvim-dap',
    "folke/neodev.nvim",
    {
        "folke/noice.nvim",
        config = function()
            require("noice").setup({ })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        }
    },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            {"nvim-lua/plenary.nvim"},
            {"nvim-treesitter/nvim-treesitter"}
        }
    },
    "luukvbaal/statuscol.nvim",
  {
      'kevinhwang91/nvim-ufo',
      dependencies = 'kevinhwang91/promise-async'
  },
}
