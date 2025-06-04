return {
  -- Configurable 'statuscolumn' and click handlers
  "luukvbaal/statuscol.nvim",
  lazy = false,
  config = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      relculright = true,
      ft_ignore = { "snacks_dashboard" },
      segments = {
        {
          sign = { name = { "Diagnostic" }, maxwidth = 1 },
          click = "v:lua.ScSa",
        },
        { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
        { text = { " " } },
        { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
        { text = { " " } },
        {
          hl = "FoldColumn",
          sign = {
            namespace = { "gitsigns" },
            maxwidth = 1,
            colwidth = 1,
            fillchar = "│",
          },
          click = "v:lua.ScSa",
        },
        { text = { " " } },
      },
    })
  end,
}
