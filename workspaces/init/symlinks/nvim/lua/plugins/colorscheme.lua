return { -- Color theme
  {
    "marko-cerovac/material.nvim",
    opts = {
      plugins = {
        "dap",
        "gitsigns",
        "indent-blankline",
        "mini",
        "nvim-cmp",
        "nvim-navic",
        "nvim-web-devicons",
        "telescope",
        "trouble",
        "which-key",
      },
      lualine_style = "default",
      custom_colors = function(colors)
        colors.git.modified = colors.main.yellow
      end,
      custom_highlights = {
        ["@text"] = { link = "Normal" },
        ["@error"] = { link = "Error" },
        FoldColumn = { link = "LineNr" },
        SignColumn = { link = "LineNr" },
        Folded = { link = "BufferLineWarningSelected" },
        AlphaHeader = { link = "@string" },
        AlphaButtons = { link = "@method" },
        AlphaShortcut = { link = "@symbol" },
        AlphaFooter = { link = "@comment" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "material",
    },
  },
}
