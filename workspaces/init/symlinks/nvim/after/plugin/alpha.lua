local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")
local button = dashboard.button
local v = vim.version()
local version = v.major .. "." .. v.minor .. "." .. v.patch
local pluginCount = #vim.tbl_keys(packer_plugins)

dashboard.section.header.val = {
	[[                                                    ]],
	[[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
	[[ ███▓╗  █▓║█▓╔════╝█▓╔═══█▓╗█▓║   █▓║█▓║███▓╗ ███▓║ ]],
	[[ ▓▒╔▓▓╗ ▓▒║▓▓▓▓▒╗  ▓▒║   ▓▒║▓▒║   ▓▒║▓▒║▓▒╔▓▓▓▒╔▓▒║ ]],
	[[ ▒▒║╚▒▒╗▒▒║▒▒╔══╝  ▒▒║   ▒▒║╚▒▒╗ ▒▒╔╝▒▒║▒▒║╚▒▒╔╝▒▒║ ]],
	[[ ░░║ ╚░░░░║░░░░░░░╗╚░░░░░░╔╝ ╚░░░░╔╝ ░░║░░║ ╚═╝ ░░║ ]],
	[[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
	[[                                                    ]],
}

--  縷     
dashboard.section.buttons.val = {
	button("e", "  New file", "<cmd>ene<CR>"),
	button("SPC p v", "  File explorer", "<cmd>Ex<CR>"),
	button("SPC p f", "  Find files", "<cmd>Telescope find_files<CR>"),
	button("CNTRL p", "  Git files", "<cmd>Telescope git_files<CR>"),
	button("SPC p t", "  Telescope", "<cmd>Telescope<CR>"),
	button("ALT -", "  Harpoon",
			'<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>'),
	button("", "痢 Update plugins", "<cmd>PackerSync<CR>"),
}

dashboard.section.footer.val = {
	"",
	"",
	"",
	pluginCount .. " plugins   " .. "   NVIM v" .. version,
	""
}
alpha.setup(dashboard.config)
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
