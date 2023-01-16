require('ufo').setup({
	provider_selector = function()
		return {'treesitter', 'indent'}
	end,
	fold_virt_text_handler = function(text, lnum, endLnum, width)
		local suffix = "  "
		local lines  = ('(%d lines) '):format(endLnum - lnum)

		local cur_width = 0
		for _, section in ipairs(text) do
			cur_width = cur_width + vim.fn.strdisplaywidth(section[1])
		end

		suffix = suffix
		  .. (' '):rep(width - cur_width - vim.fn.strdisplaywidth(lines) - 3)

		table.insert(text, { suffix, 'Folded' })
		table.insert(text, { lines, 'Folded' })
		return text
	end,
})

