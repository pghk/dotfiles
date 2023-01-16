Icons = require('pghk/ui/icons')
require('lualine').setup {
  options = {
    -- icons_enabled = true,
    theme = require('material.lualine'),
    disabled_filetypes = { "alpha" },
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
      lualine_a = { 'mode' },
      lualine_b = {
          { 'branch', icon = Icons.misc.branch }, 'diff', 'diagnostics' },
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
