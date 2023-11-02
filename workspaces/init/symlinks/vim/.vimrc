let mapleader = " "
set visualbell

set number                                            " Enable line numbers
" Use relative line numbers
if exists("&relativenumber")
	set relativenumber
	au BufReadPost * set relativenumber
endif

syntax on                                      " Enable syntax highlighting
set cursorline                                     " Highlight current line
set tabstop=2                             " Make tabs as wide as two spaces
set scrolloff=3             " Start scrolling before reaching top or bottom
set laststatus=2                                  " Always show status line

set clipboard=unnamed                                " Use the OS clipboard
set ttyfast                        " Optimize for fast terminal connections
set esckeys                              " Allow cursor keys in insert mode
set backspace=indent,eol,start             " Allow backspace in insert mode

set mouse=a                                     " Enable mouse in all modes
set nostartofline                   " Don’t reset cursor when moving around

set nocompatible                                     " Make Vim more useful
set modeline                                    " Respect modeline in files
set modelines=4

set exrc                                " Enable per-directory .vimrc files
set secure                            " and disable unsafe commands in them

set hlsearch                                           " Highlight searches
set ignorecase
set smartcase                               " Treat lowercase insensitively
set incsearch                   " Highlight dynamically as pattern is typed

filetype on                                    " Enable file type detection
filetype plugin on
filetype indent on

let g:airline_powerline_fonts = 1     " Use powerline symbols in status bar
                                              " Enable True Colors in vim 8
if (has("termguicolors"))
  set termguicolors
endif

colorscheme nova                                               " Set colors

                                                       " Automatic commands
if has("autocmd")
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif

" Move highlighted lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Replace without yanking
xnoremap <leader>p "_dP
" Delete without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Clear search highlighting with return
nnoremap silent <cr> :noh<cr><cr>
