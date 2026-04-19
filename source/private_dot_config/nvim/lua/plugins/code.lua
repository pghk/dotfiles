-- Affordances: syntax highlighting (treesitter), language server (LSP + Mason),
--              built-in completion, fold management (ufo)
-- Keymaps (active when LSP is attached):
--   K           hover documentation
--   gd          go to definition
--   gr          references
--   <leader>ca  code action
--   <leader>rn  rename symbol
--   ]d / [d     next / prev diagnostic
--   zR          open all folds
--   zM          close all folds
--   zr          open folds except kinds
--   zm          close folds with count
return {
  -- Syntax, textobjects, and fold provider
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash", "gitcommit", "html", "javascript", "json",
        "lua", "markdown", "markdown_inline", "php",
        "regex", "typescript", "vim", "yaml",
      },
      highlight = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- LSP server installer
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridges Mason with lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({ ensure_installed = { "lua_ls" } })

      -- Keymaps and built-in completion on LSP attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          map("K",           vim.lsp.buf.hover,        "Hover docs")
          map("gd",          vim.lsp.buf.definition,   "Go to definition")
          map("gr",          vim.lsp.buf.references,   "References")
          map("<leader>ca",  vim.lsp.buf.code_action,  "Code action")
          map("<leader>rn",  vim.lsp.buf.rename,       "Rename symbol")
          map("]d",          vim.diagnostic.goto_next, "Next diagnostic")
          map("[d",          vim.diagnostic.goto_prev, "Prev diagnostic")

          if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
      })

      vim.opt.completeopt:append("noselect")

      -- Server-specific configuration
      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
          },
        },
      })
    end,
  },

  -- Fold display with treesitter/LSP providers
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      require("ufo").setup({
        provider_selector = function() return { "treesitter", "indent" } end,
        fold_virt_text_handler = function(text, lnum, endLnum, width)
          local suffix = "  "
          local lines = ("(%d lines) "):format(endLnum - lnum)
          local cur_width = 0
          for _, section in ipairs(text) do
            cur_width = cur_width + vim.fn.strdisplaywidth(section[1])
          end
          suffix = suffix .. (" "):rep(width - cur_width - vim.fn.strdisplaywidth(lines) - 3)
          table.insert(text, { suffix, "Folded" })
          table.insert(text, { lines, "Folded" })
          return text
        end,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds,        { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds,       { desc = "Close all folds" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith,      { desc = "Close folds with count" })
    end,
  },
}
