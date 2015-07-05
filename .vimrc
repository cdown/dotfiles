runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()


filetype plugin on
syntax on


colorscheme solarized
set background=dark


set backupcopy=yes
set colorcolumn=+1
set expandtab
set formatoptions-=t
set hlsearch
set incsearch
set nofoldenable
set nomodeline
set nowrap
set number
set relativenumber
set shiftwidth=4
set shortmess=aoOtI
set softtabstop=4
set synmaxcol=400
set tabstop=4
set textwidth=79
set viminfo='20,<1000,s1000


let mapleader = "\<Space>"
nnoremap <Leader>w :w<CR>
nnoremap <silent> <leader>n :setlocal paste<CR>
nnoremap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
nnoremap <silent> / :let @/ = ""<CR>:set hlsearch<CR>/
nnoremap <silent> H :set hlsearch!<CR>


highlight TrailingWhitespace ctermbg=black
match TrailingWhitespace /\s\+$/


for directory in ["backup", "swap", "undo"]
  silent! call mkdir($HOME . "/.vim/" . directory, "p")
endfor
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//
set undofile


" This avoids <Leader>q getting mapped to MailQuote when in a mail file
let no_mail_maps = 1


" Do not enter ex mode when I fat finger q with shift pressed
nnoremap Q <nop>


" Do not show command history window when :q gets entered in the wrong order
map q: :q


" Use easymotion for find/til movements, with <Leader> prefixed version as
" option to use regular find/til
for key in ['f', 'F', 't', 'T']
  exe 'noremap <Leader>' . key . ' ' . key
  exe 'map ' . key . ' <Plug>(easymotion-' . key . ')'
endfor


" Do not copy to default register on delete/change, use <Leader> prefixed
" version to use regular delete/change
for key in ['d', 'D', 'c', 'C']
  for keymode in ['n', 'v']
    exe keymode . 'noremap <Leader>' . key . ' ' . key
    exe keymode . 'noremap ' . key . ' "_' . key
  endfor
endfor


" Use xfer file as custom yank/paste. It's 2014 people, why do clipboards still
" suck :-(
for keymode in ['n', 'v']
  exe keymode . 'noremap <silent> <Leader>y :w! ~/.vim/xfer<CR>'
  exe keymode . 'noremap <silent> <Leader>p :r ~/.vim/xfer<CR>'
endfor


augroup filetype_settings
  " Clear this autocmd group so that the settings won't get loaded over and
  " over again
  autocmd!

  " Seek past headers, since usually we don't want to edit them
  autocmd FileType mail normal }
  autocmd FileType mail setlocal formatoptions+=rw

  autocmd FileType make setlocal noexpandtab

  for filetype in ['yaml', 'sql', 'ruby', 'html', 'css', 'xml', 'php', 'vim']
  exe 'autocmd FileType ' . filetype . ' setlocal sw=2 sts=2 ts=2'
  endfor
augroup END


augroup modechange_settings
  autocmd!

  " Clear search context when entering insert mode, which implicitly stops the
  " highlighting of whatever was searched for with hlsearch on. It should also
  " not be persisted between sessions.
  autocmd InsertEnter * let @/ = ''
  autocmd BufReadPre,FileReadPre * let @/ = ''

  autocmd InsertLeave * setlocal nopaste
augroup END


" Do not overwrite default register when pasting in visual mode
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()
