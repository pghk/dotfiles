return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  config = function()
    require("ufo").setup({
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(text, lnum, endLnum, width)
        local suffix = "  "
        local lines = ("(%d lines) "):format(endLnum - lnum)

        local cur_width = 0
        for _, section in ipairs(text) do
          cur_width = cur_width + vim.fn.strdisplaywidth(section[1])
        end

        suffix = suffix .. (" "):rep(width - cur_width - vim.fn.strdisplaywidth(lines) - 3)

        table.insert(text, { suffix, "Folded" })
        table.insert(text, { lines, "Folded" })
        return text
      end,
    })
    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Close n folds" })
    vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Open most folds" })
  end,
}
