exe "set runtimepath=~/.vim," . $SSHHOME . ".sshrc.d/.vim," . $VIMRUNTIME

runtime! bundle/pathogen/autoload/pathogen.vim
exe "runtime! " . $SSHHOME . ".sshrc.d/.vim/bundle/pathogen/autoload/pathogen.vim"

if exists("*pathogen#infect")
  execute pathogen#infect('bundle/{}', $SSHHOME . ".sshrc.d/.vim/bundle/{}")
endif

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
set spell
set spellcapcheck=
set spelllang=en_gb
set synmaxcol=1000
set textwidth=79
set viminfo='20,<1000,s1000


let mapleader = "\<Space>"
nnoremap <Leader>w :w<CR>
nnoremap <silent> <leader>n :setlocal paste<CR>
nnoremap <silent> <leader>q :%s/\s\+$//e<CR><C-o>
nnoremap <silent> / :let @/ = ""<CR>:set hlsearch<CR>/
nnoremap <silent> H :set hlsearch!<CR>

noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

highlight TrailingWhitespace ctermbg=black
call matchadd('TrailingWhitespace', '\s\+$')

highlight SpacesBeforeTab ctermbg=darkred
call matchadd('SpacesBeforeTab', ' \+\ze\t')

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

if has('nvim')
  silent! call mkdir($HOME . "/.nvim/undo", "p")
  set undodir=~/.nvim/undo//
else
  silent! call mkdir($HOME . "/.vim/undo", "p")
  set undodir=~/.vim/undo//
endif

set undofile

" I regularly commit/push to avoid computer death, so saving swap/backup files
" locally doesn't help anyway.
set nobackup
set noswapfile
set nowritebackup

" This avoids <Leader>q getting mapped to MailQuote when in a mail file
let no_mail_maps = 1

" Do not enter ex mode when I fat finger q with shift pressed
nnoremap Q <nop>

" Do not show me man pages when I'm bad at pressing k
nnoremap K <nop>

" I'm very bad at pressing things
nmap <F1> <nop>

" Do not show command history window when :q gets entered in the wrong order
map q: :q


" When joining, do the right thing to join up function definitions
vnoremap J J:s/( /(/g<CR>:s/,)/)/g<CR>

" Quickly move around (and into) command mode
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

nnoremap <silent> <Leader>y :call writefile(getline(1, '$'), expand("~/.vim/xfer"))<CR>:silent! execute '!xclip < ' . expand("~/.vim/xfer")<CR>:silent! execute '!xclip -sel clip < ' . expand("~/.vim/xfer")<CR>:redraw!<CR>
vnoremap <silent> <Leader>y :<C-U>call writefile(getline("'<", "'>"), expand("~/.vim/xfer"))<CR>:silent! execute '!xclip < ' . expand("~/.vim/xfer")<CR>:silent! execute '!xclip -sel clip < ' . expand("~/.vim/xfer")<CR>:redraw!<CR>

" Automatically move to end of paste
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" I only really use a single mark, so M to set it, m to retrieve it
nnoremap M mA
nnoremap m 'A

augroup filetype_settings
  " Clear this autocmd group so that the settings won't get loaded over and
  " over again
  autocmd!

  autocmd BufNewFile,BufReadPost *.cconf,*.cinc,TARGETS setlocal filetype=python
  autocmd BufNewFile,BufReadPost *.lalrpop setlocal filetype=rust
  autocmd BufNewFile,BufReadPost *.def setlocal filetype=c

  " Seek past headers, since usually we don't want to edit them
  autocmd FileType mail normal }
  autocmd FileType mail setlocal formatoptions+=rw

  for filetype in ['yaml', 'sql', 'ruby', 'html', 'css', 'xml', 'php', 'vim']
    exe 'autocmd FileType ' . filetype . ' setlocal sw=2 sts=2 ts=2'
  endfor

  for filetype in ['gitcommit', 'mail', 'gitsendemail']
    exe 'autocmd FileType ' . filetype . ' setlocal joinspaces'
  endfor

  for filetype in ['gitcommit', 'gitsendemail']
    exe 'autocmd FileType ' . filetype . ' setlocal tw=72'
  endfor

  autocmd BufRead,BufNewFile ~/.local/share/nota/* setlocal filetype=markdown

  autocmd BufRead,BufNewFile */linux/*.c,*/linux/*.h setlocal textwidth=80
  autocmd BufRead,BufNewFile */systemd/*.c,*/systemd/*.h setlocal textwidth=109

  " Don't restore last file position for git buffers
  autocmd BufWinEnter */.git/* normal! gg0

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

" I only mistype :a for :q
cnoremap <expr> <CR> getcmdtype() == ":" && index(["a"], getcmdline()) >= 0 ? "<C-u>:q<CR>" : "<CR>"

" Go to conflict marker
noremap <silent> <Leader>c /^\(<<<<<<<\\|\|\|\|\|\|\|\|\\|=======\\|>>>>>>>\)<CR>

" Kernel syntax
augroup kernel_syntax
  autocmd!

  autocmd Syntax c syn keyword cStatement fallthrough
  autocmd Syntax c syn keyword cOperator likely unlikely
  autocmd Syntax c syn keyword cType u8 u16 u32 u64 s8 s16 s32 s64
  autocmd Syntax c syn keyword cType __u8 __u16 __u32 __u64 __s8 __s16 __s32 __s64
augroup END

let g:GPGDefaultRecipients=["0xDF8D21B616118070"]
