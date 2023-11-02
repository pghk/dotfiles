return {
  "stevearc/conform.nvim",
  opts = {
    ---@type table<string, conform.FormatterUnit[]>
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      php = { "php-cs-fixer" },
    },
  },
}
