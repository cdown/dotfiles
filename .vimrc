set autoindent
set autoread
set backspace=2
set colorcolumn=+1
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
set textwidth=80
set undolevels=1000
set whichwrap+=<,>,[,]

syntax on

command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

" Allow up/down to work as expected when ''wrap'' is set
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
