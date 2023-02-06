local function custom()
    local dashboard = require("alpha.themes.dashboard")
    local button = dashboard.button
    local v = vim.version()
    local version = v.major .. "." .. v.minor .. "." .. v.patch
    local plugins = require("lazy").stats()
    local home = os.getenv('HOME')
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

    dashboard.section.buttons.val = {
        button("e", "  New file", "<cmd>ene<CR>"),
        button("SPC p v", "  File explorer", "<cmd>Ex<CR>"),
        button("SPC s f", "  Find files", "<cmd>Telescope find_files<CR>"),
        button("CNTRL p", "  Git files", "<cmd>Telescope git_files<CR>"),
        button("SPC s t", "  Telescope", "<cmd>Telescope<CR>"),
        button("ALT -", "  Harpoon",
        '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>'),
        button("CNTRL ,", "  Configuration",
        "<cmd>Ex " .. home .. "/.config/nvim/ <CR>"),
        button(":Lazy", "  Manage plugins", "<cmd>Lazy<CR>"),
    }

    dashboard.section.footer.val = {
        "",
        "",
        "",
        plugins.loaded .. "/" .. plugins.count .. " plugins   "
        .. "   NVIM v" .. version,
        ""
    }

    return dashboard.config
end

return {
    'goolord/alpha-nvim',
    config = function ()
        require('alpha').setup(custom())
    end
}
