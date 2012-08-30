syntax on

set autoindent
set backspace=indent,eol,start
set expandtab
set fileencoding=utf-8
set incsearch
set listchars=tab:>-,trail:·,eol:$
set nobackup
set nowrap
set shiftwidth=4
set shortmess=aI
set tabstop=4
set textwidth=0
set whichwrap+=<,>,[,]

let mapleader = ","
nmap <silent> <leader>s :set nolist!<CR>
nmap <silent> <leader>w :set textwidth=80<CR> gqG :set textwidth=0<CR>
