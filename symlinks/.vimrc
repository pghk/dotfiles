                                                " Load Powerline status bar
source
\ ~/Library/Python/2.7/lib/python/site-packages/powerline/
\bindings/vim/plugin/powerline.vim

set laststatus=2                                  " Always show status line

filetype on                                    " Enable file type detection
filetype plugin on
filetype indent on
                                              " Enable True Colors in vim 8
if (has("termguicolors"))
  set termguicolors
endif

colorscheme OceanicNext                                        " Set colors

syntax on                                      " Enable syntax highlighting
set number                                            " Enable line numbers
set cursorline                                     " Highlight current line
set tabstop=2                             " Make tabs as wide as two spaces
set scrolloff=3             " Start scrolling before reaching top or bottom

                                                " Use relative line numbers
if exists("&relativenumber")
	set relativenumber
	au BufReadPost * set relativenumber
endif

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
set ignorecase                                    " Ignore case of searches
set incsearch                   " Highlight dynamically as pattern is typed

                                                       " Automatic commands
if has("autocmd")
	" Treat .json files as .js
	autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
	" Treat .md files as Markdown
	autocmd BufNewFile,BufRead *.md setlocal filetype=markdown
endif
