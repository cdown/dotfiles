exe "set runtimepath=~/.vim," . $SSHHOME . ".sshrc.d/.vim," . $VIMRUNTIME

runtime! bundle/pathogen/autoload/pathogen.vim
exe "runtime! " . $SSHHOME . ".sshrc.d/.vim/bundle/pathogen/autoload/pathogen.vim"

if exists("*pathogen#infect")
  execute pathogen#infect('bundle/{}', $SSHHOME . ".sshrc.d/.vim/bundle/{}")
endif

let g:neocomplete#enable_at_startup = 1

filetype plugin on
syntax on

let g:solarized_termtrans = 1
silent! colorscheme solarized
set background=dark


set autoindent
set backspace=indent,eol,start
set backupcopy=yes
set colorcolumn=+1
set cursorcolumn
set cursorline
set expandtab
set formatoptions=qrn
set hlsearch
set ignorecase
set incsearch
set linebreak
set nofoldenable
set nojoinspaces
set nowrap
set number
set relativenumber
set scrolloff=15
set shiftround
set shiftwidth=4
set shortmess=aoOtI
set smartcase
set softtabstop=4
set synmaxcol=1000
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
call matchadd('TrailingWhitespace', '\s\+$')

" I've got to stop saying this crap
highlight ShittyWords ctermbg=red ctermfg=black
call matchadd('ShittyWords', '\<\([Gg]uy\|[Dd]ude\)s\?\>')

" Since we changed solarized colour from #002b36 to #3b5a61, we need to
" explicitly set this to avoid the whole background becoming that colour
highlight Normal ctermbg=none

" Solarized colours for parens are quite bad by default, because it's difficult
" to tell which is the cursor and which is the match.
highlight MatchParen ctermbg=darkmagenta ctermfg=black

command FixFile :set fileencoding=utf-8 fileformat=unix nobomb | %s/\r$//

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

" Do not show me man pages when I'm bad at pressing k
nnoremap K <nop>


" Do not show command history window when :q gets entered in the wrong order
map q: :q


" When joining, do the right thing to join up function definitions
vnoremap J J:s/( /(/g<CR>:s/,)/)/g<CR>

" Quickly move around (and into) command mode
imap jk <Esc>
imap kj <Esc>:
for keymode in ['n', 'v']
  exec keymode . 'noremap ; :'
  exec keymode . 'noremap : ;'
endfor

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
  exe keymode . 'noremap <silent> <Leader>p :r ~/.vim/xfer<CR>'
endfor

" gV to highlight previously inserted text
nnoremap gV `[v`]

nnoremap <silent> <Leader>y :w! ~/.vim/xfer<CR>:w !xclip<CR><CR>:w !xclip -sel clip<CR><CR>'
vnoremap <silent> <Leader>y :w! ~/.vim/xfer<CR>gv:w !xclip<CR><CR>gv:w !xclip -sel clip<CR><CR>'

" Automatically move to end of paste
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

augroup filetype_settings
  " Clear this autocmd group so that the settings won't get loaded over and
  " over again
  autocmd!

  " By default, *.md is detected as modula2
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown

  autocmd BufNewFile,BufReadPost *.cconf,*.cinc,TARGETS set filetype=python

  " Seek past headers, since usually we don't want to edit them
  autocmd FileType mail normal }
  autocmd FileType mail setlocal formatoptions+=rw

  autocmd FileType make setlocal noexpandtab

  for filetype in ['yaml', 'sql', 'ruby', 'html', 'css', 'xml', 'php', 'vim']
    exe 'autocmd FileType ' . filetype . ' setlocal sw=2 sts=2 ts=2'
  endfor

  for filetype in ['gitcommit', 'mail']
    exe 'autocmd FileType ' . filetype . ' setlocal joinspaces'
  endfor

  autocmd BufRead,BufNewFile ~/.local/share/nota/* set filetype=markdown

  " Update ctags on write
  " Disabled for now due to perf
  " autocmd BufWritePost *.c,*.cpp,*.h,*.py silent! !ctags -R >/tmp/ctags.log 2>&1 &
augroup END

nnoremap <C-l> <C-l>zz

augroup modechange_settings
  autocmd!

  " Clear search context when entering insert mode, which implicitly stops the
  " highlighting of whatever was searched for with hlsearch on. It should also
  " not be persisted between sessions.
  autocmd InsertEnter * let @/ = ''
  autocmd BufReadPre,FileReadPre * let @/ = ''

  autocmd InsertLeave * setlocal nopaste

  " Jump to last position in file
  autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

  " Balance splits on window resize
  autocmd VimResized * wincmd =
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

" Stock replies
nnoremap <silent> <Leader>R gg:normal }<CR>jdG:r ~/.config/mutt/replies/recruiter<CR><Leader>f,i

" Stuff to make working with unwrapped text easier
for key in ['k', 'j']
  exe 'noremap <buffer> <silent> <expr> ' . key . ' v:count ? ''' . key . ''' : ''g' . key . ''''
  exe 'onoremap <silent> <expr> ' . key . ' v:count ? ''' . key . ''' : ''g' . key . ''''
endfor
nnoremap <silent> <Leader>E :set wrap<CR>:setlocal formatoptions-=t<CR>:set textwidth=0<CR>
nnoremap <silent> <Leader>e :set nowrap<CR>:setlocal formatoptions+=t<CR>:set textwidth=79<CR>

let g:GPGDefaultRecipients=["0xDF8D21B616118070"]
