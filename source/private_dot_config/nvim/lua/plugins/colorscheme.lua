return { -- Color theme
  {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
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
        DashboardHeader = { link = "@string" },
        DashboardFooter = { link = "@property" },
        DashboardIcon = { link = "@symbol" },
        DashboardDesc = { link = "@text" },
        DashboardKey = { link = "@type" },
        DashboardShortCut = { link = "@operator" },
        MiniIndentscopeSymbol = { link = "@method" },
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
