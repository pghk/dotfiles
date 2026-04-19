-- Affordances: text surround/unwrap, auto-formatting on save, indent detection,
--              undo history visualization, kitty config syntax
-- Keymaps:
--   <leader>u   toggle undo tree
--   (surround keymaps: ys, ds, cs — see nvim-surround docs)
return {
  -- Surround text objects (ys, ds, cs)
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", config = true },

  -- Format on save
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      formatters_by_ft = {
        lua = { "stylua" },
        sh  = { "shfmt" },
        php = { "php-cs-fixer" },
      },
    },
  },

  -- Auto-detect tabstop and shiftwidth from file
  "tpope/vim-sleuth",

  -- Undo history visualizer
  {
    "mbbill/undotree",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undo tree" } },
  },

  -- Syntax highlighting for Kitty terminal config
  { "fladson/vim-kitty" },
}
