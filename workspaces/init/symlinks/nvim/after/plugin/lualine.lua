local colors = {
    rose = '#ebbcba',
    pine = '#31748f',
    iris = '#c4a7e7',
    foam = '#9ccfd8',
    love = '#eb6f92',
    gold = '#f6c177',
    base = '#232136',
    surface = '#2a273f',
    overlay = '#393552',
    muted = '#6e6a86',
    subtle = '#908caa',
    text = '#e0def4',
    highlight_low = '#2a283e',
    highlight_med = '#44415a',
    highlight_high = '#56526e',
}

local function getTheme ()
    return {
        normal = {
            a = { fg = colors.base, bg = colors.rose, gui = 'bold' },
            b = { fg = colors.subtle, bg = colors.overlay},
            c = { fg = colors.subtle, bg = colors.surface},
        },
        command = { a = { fg = colors.base, bg = colors.gold, gui = 'bold' } },
        insert = { a = { fg = colors.base, bg = colors.pine, gui = 'bold' } },
        visual = { a = { fg = colors.base, bg = colors.iris, gui = 'bold' } },
        terminal = { a = { fg = colors.base, bg = colors.foam, gui = 'bold' } },
        replace = { a = { fg = colors.base, bg = colors.love, gui = 'bold' } },
        inactive = {
            a = { fg = colors.muted, bg = colors.base, gui = 'bold' },
            b = { fg = colors.muted, bg = colors.base},
            c = { fg = colors.muted, bg = colors.highlight_med},
        },
    }
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = getTheme(),
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { 'filename' },
      lualine_x = {
	'encoding',
	{ 'fileformat', icons_enabled = false },
	'filetype'
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' }
  },
}
