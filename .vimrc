syntax on

set autoindent
set backspace=indent,eol,start
set expandtab
set fileencoding=utf-8
set incsearch
set listchars=tab:>-,trail:.,eol:$
set nobackup
set nowrap
set shiftwidth=4
set shortmess=aI
set tabstop=4
set whichwrap+=<,>,[,]

autocmd FileType make setlocal noexpandtab

let mapleader = ","
nmap <silent> <leader>s :set nolist!<CR>
