return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signcolumn = true,
    numhl = false,
    signs = {
      add = { text = "│ " },
      change = { text = "│ " },
      delete = { text = "└" },
      topdelete = { text = "┌" },
      changedelete = { text = "┼" },
      untracked = { text = "┆" },
    },
  },
}
