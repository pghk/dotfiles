-- Affordances: git change indicators in gutter, hunk staging, blame, full git operations
-- Keymaps:
--   <leader>gs  git status (fugitive)
--   <leader>gb  git blame toggle
--   ]h / [h     next / prev hunk
--   <leader>hs  stage hunk
--   <leader>hr  reset hunk
return {
  -- Git signs in gutter + hunk operations
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signcolumn = true,
      numhl = false,
      signs = {
        add          = { text = "│ " },
        change       = { text = "│ " },
        delete       = { text = "└" },
        topdelete    = { text = "┌" },
        changedelete = { text = "┼" },
        untracked    = { text = "┆" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = desc })
        end
        map("]h",          gs.next_hunk,         "Next hunk")
        map("[h",          gs.prev_hunk,         "Prev hunk")
        map("<leader>hs",  gs.stage_hunk,        "Stage hunk")
        map("<leader>hr",  gs.reset_hunk,        "Reset hunk")
        map("<leader>gb",  gs.toggle_current_line_blame, "Blame toggle")
      end,
    },
  },

  -- Full git integration (commit, push, diff, log, etc.)
  {
    "tpope/vim-fugitive",
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "Git status" },
    },
  },
}
