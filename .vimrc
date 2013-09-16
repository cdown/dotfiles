runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on

filetype on
filetype plugin indent on

highlight ColorColumn ctermbg=0
highlight MatchParen ctermbg=white ctermfg=black

if exists('+colorcolumn')
    set colorcolumn=80
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
set timeoutlen=250
set viminfo-=<50,s10
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
autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions=tcrq
autocmd FileType make setlocal noexpandtab
autocmd FileType ruby setlocal shiftwidth=4
autocmd FileType ruby setlocal tabstop=4
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * setlocal nopaste

let g:EasyMotion_leader_key = '<Leader>'
let mapleader = ","


nmap <silent> <leader>p :set paste<CR>
