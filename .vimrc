syntax on

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
    let numTabs=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^\\t"'))
    let numSpaces=len(filter(getbufline(bufname("%"), 1, 250), 'v:val =~ "^ "'))
    if numTabs > numSpaces
        setlocal noexpandtab
    endif
endfunction

autocmd FileType make setlocal noexpandtab
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * set nopaste
autocmd BufWritePre * %s/\s\+$//e
autocmd BufReadPost * call TabsOrSpaces()

nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

let mapleader = ","
nmap <silent> <leader>p :set paste<CR>
map  <silent> <leader>c :s/^/#/<CR>:let @/ = ""<CR>
map  <silent> <leader>u :s/^#//<CR>
