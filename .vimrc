runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()

syntax on
filetype plugin indent on

highlight ColorColumn ctermbg=black
highlight CursorLineNr ctermfg=darkgrey
highlight LineNr ctermfg=black
highlight MatchParen ctermbg=white ctermfg=black
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
set nowrap
set shiftwidth=4
set shortmess=aI
set tabstop=4
set textwidth=79

autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=r textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2
autocmd FileType gitcommit setlocal textwidth=72

let mapleader = ","
let g:EasyMotion_leader_key = '<Leader>'

nnoremap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
inoremap jj <Esc>

for key in ["f", "F", "t", "T"]
    exe "map " . key . " <Plug>(easymotion-" . key . ")"
endfor

for prefix in ['i', 'n', 'v']
    for key in ['<Up>', '<Down>', '<Left>', '<Right>', '<F1>']
        exe prefix . "noremap " . key . " <NOP>"
    endfor
endfor
