local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- Prevent nvim-ufo from folding/unfolding unexpectedly
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.undodir"
opt.undofile = true

opt.hlsearch = false
opt.incsearch = true

opt.termguicolors = true

opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")
opt.colorcolumn = "80"
opt.updatetime = 100

local testDiagnostics = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({virtual_text = true}, testDiagnostics)

