runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()

colorscheme solarized

for directory in ["backup", "swap", "undo"]
    silent! call mkdir($HOME . "/.vim/" . directory, "p")
endfor

let no_mail_maps = 1

syntax on
filetype plugin indent on

highlight ColorColumn ctermbg=black
highlight TrailingWhitespace ctermbg=black

match TrailingWhitespace /\s\+$/

set autoindent
set backspace=indent,eol,start
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set expandtab
set formatoptions-=t
set incsearch
set nowrap
set number
set shiftwidth=4
set shortmess=aI
set softtabstop=4
set tabstop=4
set textwidth=79

silent! set colorcolumn=+1
silent! set relativenumber
silent! set undodir=~/.vim/undo//
silent! set undofile

autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=rw textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd FileType yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType gitcommit setlocal textwidth=72
autocmd InsertLeave * setlocal nopaste

let g:EasyMotion_leader_key = '<Leader>'

nnoremap <silent> <leader>p :setlocal paste<CR>
nnoremap <silent> <leader>q :%s/\s\+$//e<CR><C-o>

for key in ["f", "F", "t", "T"]
    exe "noremap <Leader>" . key . " " . key
    exe "map " . key . " <Plug>(easymotion-" . key . ")"
endfor

for prefix in ['i', 'n', 'v']
    for key in ['<Up>', '<Down>', '<Left>', '<Right>', '<F1>']
        exe prefix . "noremap " . key . " <NOP>"
    endfor
endfor
