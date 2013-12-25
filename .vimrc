runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on

filetype on
filetype plugin indent on

highlight ColorColumn ctermbg=black
highlight CursorLineNr ctermfg=darkgrey
highlight LineNr ctermfg=black
highlight MatchParen ctermbg=white ctermfg=black
highlight Search ctermbg=white ctermfg=black
highlight TrailingWhitespace ctermbg=black
highlight Visual ctermbg=white ctermfg=black

match TrailingWhitespace /\s\+$/

set autoindent
set backupdir=~/.vim/backup//
set colorcolumn=+1
set directory=~/.vim/swap//
set expandtab
set formatoptions-=t
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

autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=r
autocmd FileType mail setlocal textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd FileType ruby setlocal shiftwidth=2
autocmd FileType ruby setlocal tabstop=2
autocmd FileType gitcommit setlocal textwidth=72
autocmd InsertEnter * setlocal nohlsearch
autocmd InsertLeave * setlocal nopaste
autocmd InsertLeave * setlocal hlsearch

let mapleader = ","

nmap <silent> <leader>p :set paste<CR>
nmap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
