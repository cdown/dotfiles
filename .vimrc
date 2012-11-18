syntax on

let loaded_matchparen = 1

set autoindent
set backspace=indent,eol,start
set expandtab
set fileencoding=utf-8
set formatoptions+=r
set fileformats=unix
set hlsearch
set incsearch
set listchars=tab:>-,trail:.,eol:$
set mouse=a
set nobackup
set nowrap
set shiftwidth=4
set shortmess=aI
set tabstop=4
set whichwrap+=<,>,[,]

autocmd FileType make setlocal noexpandtab
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * set nopaste

let mapleader = ","
nmap <silent> <leader>s :set nolist!<CR>
nmap <silent> <leader>p :set paste<CR>
