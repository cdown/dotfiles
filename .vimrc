execute pathogen#infect()

syntax on

filetype on
filetype plugin indent on

highlight MatchParen ctermbg=white ctermfg=black

set autoindent
set backspace=indent,eol,start
set expandtab
set fileencoding=utf-8
set fileformats=unix
set hlsearch
set incsearch
set lazyredraw
set nobackup
set nowrap
set shiftwidth=4
set shortmess=aI
set tabstop=4
set whichwrap+=<,>,[,]

autocmd BufWritePre * %s/\s\+$//e
autocmd FileType make setlocal noexpandtab
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * set nopaste

let g:EasyMotion_leader_key = '<Leader>'
let mapleader = ","

nmap <silent> <leader>p :set paste<CR>
