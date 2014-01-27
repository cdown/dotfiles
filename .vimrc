runtime bundle/pathogen/autoload/pathogen.vim
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

if exists('+colorcolumn')
    set colorcolumn=+1
endif

if exists("&relativenumber")
    set relativenumber
else
    set number
endif

if exists("&undofile")
    set undodir=~/.vim/undo//
    set undofile
endif

set autoindent
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set expandtab
set formatoptions-=t
set incsearch
set hlsearch
set nowrap
set scrolloff=1
set shiftwidth=4
set shortmess=aI
set tabstop=4
set textwidth=79
set viminfo-=<50,s10

autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=r textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType gitcommit setlocal textwidth=72
autocmd InsertLeave * setlocal nopaste

let mapleader = ","
let g:EasyMotion_leader_key = '<Leader>'

nnoremap <silent> / :let @/ = ""<CR>:set hlsearch<CR>/
nmap <silent> H :set hlsearch!<CR>
nmap <silent> <leader>p :set paste<CR>
nmap <silent> <leader>q :%s/\s\+$//e<CR><C-o>

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
