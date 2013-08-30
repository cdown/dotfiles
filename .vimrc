runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on

filetype on
filetype plugin indent on

highlight ColorColumn ctermbg=0
highlight MatchParen ctermbg=white ctermfg=black

if exists('+colorcolumn')
    set colorcolumn=+1
endif

set autoindent
set backspace=indent,eol,start
set expandtab
set fileencoding=utf-8
set fileformats=unix
set foldmethod=indent
set foldlevel=99
set hlsearch
set incsearch
set lazyredraw
set nobackup
set nowrap
set shiftwidth=4
set shortmess=aI
set tabstop=4
set textwidth=79
set timeoutlen=250
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

autocmd BufWritePre * %s/\s\+$//e
autocmd BufReadPost * call TabsOrSpaces()
autocmd FileType make setlocal noexpandtab
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * setlocal nopaste

let g:EasyMotion_leader_key = '<Leader>'
let mapleader = ","

autocmd FileType mail setlocal formatoptions=tcrq
autocmd FileType mail normal }

nmap <silent> <leader>p :set paste<CR>
