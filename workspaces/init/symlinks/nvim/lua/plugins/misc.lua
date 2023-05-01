return {
  "mbbill/undotree", -- Undo history vizualizer
  "tpope/vim-fugitive", -- Git integration
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
  { -- Show a colorcolumn when width exceeded
    "m4xshen/smartcolumn.nvim",
    opts = {
      disabled_filetypes = {
        "Lazy",
        "alpha",
        "help",
        "lazy",
        "markdown",
        "mason",
        "netrw",
        "noice",
        "text",
      },
    },
  },
}
