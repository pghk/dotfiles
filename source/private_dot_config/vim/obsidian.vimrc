let mapleader = " "
set ignorecase
set smartcase
set hlsearch
set incsearch

" Delete / replace without yanking
nnoremap <leader>d "_d
vnoremap <leader>d "_d
xnoremap <leader>p "_dP

" Clear search highlighting
nnoremap <silent> <CR> :noh<CR>

" Tab navigation (Obsidian commands)
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:prev-tab
nmap <S-l> nextTab
nmap <S-h> prevTab

" Line movement — single-line only (CodeMirror-vim has no :m command)
exmap moveLineDown obcommand editor:swap-line-down
exmap moveLineUp obcommand editor:swap-line-up
nmap J moveLineDown
nmap K moveLineUp
