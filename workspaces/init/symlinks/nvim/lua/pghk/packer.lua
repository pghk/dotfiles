local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
    -- This package manager itself
    use 'wbthomason/packer.nvim'

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim', branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }

    -- Color theme
    use({
        'kaicataldo/material.vim', branch = 'main',
        config = function ()
           -- require('material').setup({}) -  
            vim.g["material_terminal_italics"] = 1
            vim.cmd('colorscheme material')
            vim.api.nvim_set_hl(0, 'ColorColumn', { link = "MsgSeparator" })
            local gray = vim.api.nvim_get_hl_by_name('MsgSeparator', true)
            local color = vim.api.nvim_get_hl_by_name('DiffChange', true)
            vim.api.nvim_set_hl(0, 'Folded', {
                bg = gray.background,
                fg = color.foreground,
                italic = true
            })
        end
    })

    -- Syntax awareness
    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

    use('theprimeagen/harpoon') -- Quick navigation between files
    use('mbbill/undotree') -- Undo history vizualizer
    use('tpope/vim-fugitive') -- Git integration
    use 'nvim-lualine/lualine.nvim' -- Fancier statusline
    use 'tpope/vim-sleuth' -- Detect tabstop and shiftwidth automatically
    use 'goolord/alpha-nvim'

    -- "gc" to comment visual regions/lines
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    -- Add/change/delete surrounding delimiter pairs
    use({
        "kylechui/nvim-surround",
        tag = "*",
        config = function()
            require("nvim-surround").setup({ })
        end
    })

    use {
      'VonHeikemen/lsp-zero.nvim',
      requires = {
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
  }

  use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

  if packer_bootstrap then
    require('packer').sync()
  end

end)
