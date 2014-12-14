runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()

colorscheme solarized
set background=dark

for directory in ["backup", "swap", "undo"]
    silent! call mkdir($HOME . "/.vim/" . directory, "p")
endfor

let no_mail_maps = 1

syntax on
filetype plugin indent on

highlight ColorColumn ctermbg=black
highlight MatchParen ctermbg=white ctermfg=black
highlight Search ctermbg=white ctermfg=black
highlight TrailingWhitespace ctermbg=black

match TrailingWhitespace /\s\+$/

set autoindent
set backspace=indent,eol,start
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set expandtab
set formatoptions-=t
set hlsearch
set incsearch
set hlsearch
set nowrap
set number
set shiftwidth=4
set shortmess=aoOtI
set softtabstop=4
set tabstop=4
set textwidth=79

silent! set colorcolumn=+1
silent! set relativenumber
silent! set undodir=~/.vim/undo//
silent! set undofile

autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby

autocmd FileType crontab setlocal backupcopy=yes
autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=rw textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd FileType yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType sql setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType ruby setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType gitcommit setlocal textwidth=72
autocmd InsertEnter * setlocal nohlsearch
autocmd InsertLeave * setlocal nopaste hlsearch

let mapleader = "\<Space>"
let g:EasyMotion_leader_key = '<Leader>'
let g:auto_save = 1

nnoremap <silent> <leader>p :setlocal paste<CR>
nnoremap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
nnoremap <silent> / :let @/ = ""<CR>:set hlsearch<CR>/
nnoremap <silent> H :set hlsearch!<CR>

inoremap kj <Esc>
inoremap jk <C-o>:w<CR>

nnoremap Q <nop>

nnoremap <Leader>o :CtrlP<CR>
nnoremap <Leader>w :w<CR>

for key in ["f", "F", "t", "T"]
    exe "noremap <Leader>" . key . " " . key
    exe "map " . key . " <Plug>(easymotion-" . key . ")"
endfor

for prefix in ['i', 'n', 'v']
    for key in ['<Up>', '<Down>', '<Left>', '<Right>', '<F1>']
        exe prefix . "noremap " . key . " <NOP>"
    endfor
endfor
