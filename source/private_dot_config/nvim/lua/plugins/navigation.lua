-- Affordances: file tree, fuzzy finding (files/text/buffers), session persistence
-- Keymaps:
--   <leader>e   file tree (toggle)
--   <leader>ff  find files
--   <leader>fg  live grep
--   <leader>fb  buffers
--   <leader>fh  help tags
return {
  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-mini/mini.icons",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "File tree" },
    },
    opts = {
      default_component_configs = {
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
        },
        modified = { symbol = "[+]" },
        git_status = {
          symbols = {
            added = "", modified = "", deleted = "", renamed = "",
            untracked = "󰡖", ignored = "", unstaged = "󰄱", staged = "󰄵", conflict = "",
          },
        },
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>",  desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",     desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",   desc = "Help tags" },
    },
  },

  -- Session persistence (used by dashboard restore action)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },
}
