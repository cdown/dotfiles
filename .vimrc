set autoindent
set backspace=2
set encoding=utf-8
set expandtab
set incsearch
set nobackup
set nocompatible
set nowrap
set shiftwidth=4
set shortmess=atI
set smartcase
set tabstop=4
set undolevels=1000
set whichwrap+=<,>,[,]

syntax on

" Allow up/down to work as expected when ''wrap'' is set
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
