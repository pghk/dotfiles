-- add more treesitter parsers
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "html",
      "javascript",
      "json",
      "lua",
      "gitcommit",
      "markdown",
      "markdown_inline",
      "regex",
      "php",
      "typescript",
      "vim",
      "yaml",
    },
  },
}
