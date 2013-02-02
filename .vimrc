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

function TabsOrSpaces()
    if getfsize(bufname("%")) > 256000
        return
    endif

    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^ "'))

    if numTabs > numSpaces
        setlocal noexpandtab
    endif
endfunction

autocmd BufReadPost * call TabsOrSpaces()
autocmd BufWritePre * %s/\s\+$//e
autocmd FileType make setlocal noexpandtab
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * set nopaste

let mapleader = ","
nmap <silent> <leader>p :set paste<CR>
