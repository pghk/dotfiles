-- Affordances: color theme, statusline, indent guides, status column, line length indicator, dashboard
-- Keymaps: (none — appearance is passive)
return {
  -- Icons (used by lualine, neo-tree, dashboard)
  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- Color scheme
  {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      plugins = { "gitsigns", "mini", "trouble" },
      lualine_style = "default",
      custom_colors = function(colors)
        colors.git.modified = colors.main.yellow
      end,
      custom_highlights = {
        FoldColumn = { link = "LineNr" },
        SignColumn = { link = "LineNr" },
        Folded = { link = "BufferLineWarningSelected" },
        MiniIndentscopeSymbol = { link = "@method" },
      },
    },
    config = function(_, opts)
      require("material").setup(opts)
      vim.cmd("colorscheme material")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icon = "󰘬" },
          { "diff", symbols = { added = " ", modified = " ", removed = " " } },
          { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = " " } },
        },
        lualine_c = {
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "*", readonly = " 󰍁", unnamed = "" } },
        },
        lualine_x = {},
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {},
      },
    },
  },

  -- Indent scope indicator
  {
    "echasnovski/mini.indentscope",
    config = function()
      require("mini.indentscope").setup({ symbol = "│" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "dashboard", "help", "lazy", "mason", "neo-tree" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- Custom status column (line numbers, fold, git signs)
  {
    "luukvbaal/statuscol.nvim",
    lazy = false,
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        ft_ignore = { "dashboard" },
        segments = {
          { sign = { name = { "Diagnostic" }, maxwidth = 1 }, click = "v:lua.ScSa" },
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { " " } },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " " } },
          {
            hl = "FoldColumn",
            sign = { namespace = { "gitsigns" }, maxwidth = 1, colwidth = 1, fillchar = "│" },
            click = "v:lua.ScSa",
          },
          { text = { " " } },
        },
      })
    end,
  },

  -- Colorcolumn that appears only when line length is exceeded
  {
    "m4xshen/smartcolumn.nvim",
    opts = {
      disabled_filetypes = {
        "dashboard", "help", "lazy", "markdown", "mason", "neo-tree", "netrw", "text",
      },
    },
  },

  -- Start screen
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "echasnovski/mini.icons" },
    opts = function()
      local logo = [[
████╗    ███╗ ████████╗  ████████╗  ███╗   ███╗ ███╗ ████╗    ████╗
█████╗   ███║ ███╔════╝ ███╔═══███╗ ███║   ███║ ███║ █████╗  █████║
███╔███╗ ███║ ██████╗   ███║   ███║ ███║   ███║ ███║ ███╔█████╔███║
███║ ███╗███║ ███╔══╝   ███║   ███║ ╚███╗ ███╔╝ ███║ ███║╚███╔╝███║
███║  ╚█████║ ████████╗ ╚████████╔╝  ╚█████╔╝   ███║ ███║ ╚═╝  ███║
╚══╝   ╚════╝ ╚═══════╝  ╚══════╝     ╚════╝    ╚══╝ ╚══╝      ╚══╝
      ]]

      logo = string.rep("\n", 4) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = { statusline = false },
        config = {
          header = vim.split(logo, "\n"),
          -- stylua: ignore
          center = {
            { action = "Telescope find_files",                                                             desc = " Find file",       icon = " ", key = "f" },
            { action = "ene | startinsert",                                                                desc = " New file",        icon = " ", key = "n" },
            { action = "Telescope oldfiles",                                                               desc = " Recent files",    icon = " ", key = "r" },
            { action = "Telescope live_grep",                                                              desc = " Find text",       icon = " ", key = "g" },
            { action = "Telescope find_files cwd=" .. vim.fn.stdpath("config"),                            desc = " Config",          icon = " ", key = "c" },
            { action = function() require("persistence").load() end,                                       desc = " Restore Session", icon = " ", key = "s" },
            { action = "Lazy",                                                                             desc = " Lazy",            icon = "󰒲 ", key = "l" },
            { action = "qa",                                                                               desc = " Quit",            icon = " ", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            local v = vim.version()
            return {
              stats.loaded .. "/" .. stats.count .. " plugins    loaded in " .. ms .. "ms    NVIM v"
                .. v.major .. "." .. v.minor .. "." .. v.patch,
            }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
      end

      return opts
    end,
  },
}
