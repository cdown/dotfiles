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
highlight Folded cterm=NONE ctermfg=10

set fillchars=fold:\ 

match TrailingWhitespace /\s\+$/

set autoindent
set backspace=indent,eol,start
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set expandtab
set formatoptions-=t
set hlsearch
set incsearch
set nofoldenable
set nomodeline
set nowrap
set number
set shiftwidth=4
set shortmess=aoOtI
set softtabstop=4
set synmaxcol=400
set tabstop=4
set textwidth=79

silent! set colorcolumn=+1
silent! set relativenumber
silent! set undodir=~/.vim/undo//
silent! set undofile

autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby
autocmd BufRead,BufNewFile TARGETS set filetype=python

autocmd FileType crontab setlocal backupcopy=yes
autocmd FileType mail normal }
autocmd FileType mail setlocal formatoptions+=rw textwidth=72
autocmd FileType make setlocal noexpandtab
autocmd Filetype python setlocal foldenable foldmethod=syntax
autocmd FileType gitcommit setlocal textwidth=72
autocmd InsertEnter * let @/ = ''
autocmd InsertLeave * setlocal nopaste

for ft in ['yaml', 'sql', 'ruby', 'html', 'css', 'xml']
    exe 'autocmd FileType ' . ft . ' setlocal sw=2 sts=2 ts=2'
endfor

let mapleader = "\<Space>"
let g:EasyMotion_leader_key = '<Leader>'
let g:auto_save = 1

nnoremap <silent> <leader>n :setlocal paste<CR>
nnoremap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
nnoremap <silent> / :let @/ = ""<CR>:set hlsearch<CR>/
nnoremap <silent> H :set hlsearch!<CR>

inoremap kj <Esc>
inoremap jk <C-o>:w<CR>

nnoremap Q <nop>

" it's 2014 people, why do clipboards still suck
nnoremap <silent> <Leader>y :w! ~/.vim/xfer<CR>
nnoremap <silent> <Leader>p :r ~/.vim/xfer<CR>
vnoremap <silent> <Leader>y :w! ~/.vim/xfer<CR>
vnoremap <silent> <Leader>p :r ~/.vim/xfer<CR>

" jump to end of paste
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

nnoremap <silent> <Leader>c :s/.*/\="['" . join(split(submatch(0), ' '), "', '") . "']"/<CR>

nnoremap <Leader><Leader> :

" do not show command history window
map q: :q

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
let g:unite_data_directory='~/.vim/.cache/unite'
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable=1
let g:unite_prompt='» '
let g:unite_split_rule='botright'
if executable('ag')
    let g:unite_source_grep_command='ag'
    let g:unite_source_grep_default_opts='--nocolor --nogroup -S -C4'
    let g:unite_source_grep_recursive_opt=''
endif
nnoremap <silent> <C-p> :Unite -auto-resize file file_mru file_rec<cr>
nnoremap <leader>y :<C-u>Unite history/yank<CR>

nnoremap <Leader>w :w<CR>

for key in ["f", "F", "t", "T"]
    exe "noremap <Leader>" . key . " " . key
    exe "map " . key . " <Plug>(easymotion-" . key . ")"
endfor

" vp doesn't replace paste buffer
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()
