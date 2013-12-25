runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on

filetype on
filetype plugin indent on

highlight ColorColumn ctermbg=black
highlight MatchParen ctermbg=white ctermfg=black
highlight Search ctermbg=white ctermfg=black
highlight Visual ctermbg=white ctermfg=black
highlight LineNr ctermfg=black
highlight CursorLineNr ctermfg=darkgrey

set autoindent
set backspace=indent,eol,start
set backupdir=~/.vim/backup//
set colorcolumn=+1
set directory=~/.vim/swap//
set expandtab
set formatoptions-=t
set hlsearch
set incsearch
set nowrap
set relativenumber
set scrolloff=1
set shiftwidth=4
set shortmess=aI
set tabstop=4
set textwidth=79
set undodir=~/.vim/undo//
set undofile
set viminfo-=<50,s10
set whichwrap+=<,>,[,]

autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=r
autocmd FileType mail setlocal textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd FileType ruby setlocal shiftwidth=2
autocmd FileType ruby setlocal tabstop=2
autocmd FileType gitcommit setlocal textwidth=72
autocmd InsertEnter * let @/ = ""
autocmd InsertLeave * setlocal nopaste

highlight TrailingWhitespace ctermbg=black
match TrailingWhitespace /\s\+$/

let g:EasyMotion_leader_key = '<Leader>'
let mapleader = ","

nmap <silent> <leader>p :set paste<CR>
nmap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
