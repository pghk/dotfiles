return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
      },
      modified = {
        symbol = "[+]",
        highlight = "NeoTreeModified",
      },
      git_status = {
        symbols = {
          -- Change type
          added = "",
          modified = "",
          deleted = "",
          renamed = "",
          -- Status type
          untracked = "󰡖",
          ignored = "",
          unstaged = "󰄱",
          staged = "󰄵",
          conflict = "",
        },
      },
    },
  },
}
