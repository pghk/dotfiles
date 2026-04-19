return {
  "nvim-mini/mini.indentscope",
  config = function()
    require("mini.indentscope").setup({
      symbol = "│",
    })
  end,
}
