"=============================================================================
" FILE: file_base.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
if !exists('g:unite_kind_file_preview_max_filesize')
  let g:unite_kind_file_preview_max_filesize = 1000000
endif
"}}}

function! unite#kinds#file_base#define() "{{{
  return s:kind
endfunction"}}}

let s:kind = {
      \ 'name' : 'file_base',
      \ 'default_action' : 'open',
      \ 'action_table' : {},
      \ 'parents' : [],
      \}

" Actions "{{{
let s:kind.action_table.open = {
      \ 'description' : 'open files',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.open.func(candidates) "{{{
  for candidate in a:candidates
    if buflisted(candidate.action__path)
      execute 'buffer' bufnr(candidate.action__path)
    else
      call s:execute_command('edit', candidate)
    endif

    call unite#remove_previewed_buffer_list(bufnr(candidate.action__path))
  endfor
endfunction"}}}

let s:kind.action_table.preview = {
      \ 'description' : 'preview file',
      \ 'is_quit' : 0,
      \ }
function! s:kind.action_table.preview.func(candidate) "{{{
  let buflisted = buflisted(a:candidate.action__path)
  if !filereadable(a:candidate.action__path)
    return
  endif

  if getfsize(a:candidate.action__path) >
        \ g:unite_kind_file_preview_max_filesize
    call unite#print_error(printf(
          \ '[unite.vim] The file size of "%s" is too huge.' ,
          \    a:candidate.action__path))
    return
  endif

  " If execute this command, unite.vim will be affected by events.
  call unite#view#_preview_file(a:candidate.action__path)

  let winnr = winnr()
  wincmd P
  try
    if !buflisted
      doautocmd BufRead
      setlocal nomodified
      call unite#add_previewed_buffer_list(a:candidate.action__path)
    endif
  finally
    execute winnr.'wincmd w'
  endtry
endfunction"}}}


let s:kind.action_table.mkdir = {
      \ 'description' : 'make this directory and parents directory',
      \ 'is_quit' : 0,
      \ 'is_invalidate_cache' : 1,
      \ }
function! s:kind.action_table.mkdir.func(candidate) "{{{
  let dirname = input('New directory name: ',
        \ a:candidate.action__path, 'dir')
  redraw

  if dirname == ''
    echo 'Canceled.'
    return
  endif

  if filereadable(dirname) || isdirectory(dirname)
    echo dirname . ' is already exists.'
  elseif !unite#util#is_sudo()
    call mkdir(dirname, 'p')
  endif
endfunction"}}}

let s:kind.action_table.rename = {
      \ 'description' : 'rename files',
      \ 'is_quit' : 0,
      \ 'is_invalidate_cache' : 1,
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.rename.func(candidates) "{{{
  for candidate in a:candidates
    let filename = unite#util#substitute_path_separator(
          \ unite#util#expand(input(printf('New file name: %s -> ',
          \ candidate.action__path), candidate.action__path)))
    redraw
    if filename != '' && filename !=# candidate.action__path
      call unite#kinds#file#do_rename(candidate.action__path, filename)
    endif
  endfor
endfunction"}}}

let s:kind.action_table.backup = {
      \ 'description' : 'backup files',
      \ 'is_quit' : 0,
      \ 'is_invalidate_cache' : 1,
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.backup.func(candidates) "{{{
  for candidate in a:candidates
    let filename = candidate.action__path . '.' . strftime('%y%m%d_%H%M')

    call unite#sources#file#copy_files(filename, [candidate])
  endfor
endfunction"}}}

let s:kind.action_table.read = {
      \ 'description' : ':read files',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.read.func(candidates) "{{{
  for candidate in a:candidates
    call s:execute_command('read', candidate)
  endfor
endfunction"}}}

let s:kind.action_table.wunix = {
      \ 'description' : 'write by unix fileformat',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.wunix.func(candidates) "{{{
  let current_bufnr = bufnr('%')

  for candidate in a:candidates
    let is_listed = buflisted(candidate.action__path)
    call s:kind.action_table.open.func([candidate])
    write ++fileformat=mac
    if is_listed
      call s:kind.action_table.open.func([candidate])
    else
      let bufnr = bufnr(candidate.action__path)
      silent execute bufnr 'bdelete'
    endif
  endfor

  execute 'buffer' current_bufnr
endfunction"}}}

let s:kind.action_table.diff = {
      \ 'description' : 'diff with the other candidate or current buffer',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.diff.func(candidates)
  if !empty(filter(copy(a:candidates), 'isdirectory(v:val.action__path)'))
    echo 'Invalid files.'
    return
  endif

  if len(a:candidates) == 1
    " :vimdiff with current buffer.
    let winnr = winnr()

    if &filetype ==# 'vimfiler'
      " Move to other window.
      wincmd w
    endif

    try
      " Use selected candidates or current buffer.
      if &filetype ==# 'vimfiler'
        let file = get(vimfiler#get_marked_files(), 0, vimfiler#get_file())
        if empty(file) || isdirectory(file.action__path)
          echo 'Invalid candidate is detected.'
          return
        elseif len(vimfiler#get_marked_files()) > 1
          echo 'Too many candidates!'
          return
        endif

        let path = file.action__path
      else
        let path = bufname('%')
      endif
    finally
      if winnr() != winnr
        " Restore window.
        execute winnr.'wincmd w'
      endif
    endtry

    execute 'tabnew' path

    let t:title = 'vimdiff'
    call s:execute_command('vert diffsplit', a:candidates[0])
  elseif len(a:candidates) == 2
    " :vimdiff the other candidate.
    call s:execute_command('tabnew', a:candidates[0])
    let t:title = 'vimdiff'
    call s:execute_command('vert diffsplit', a:candidates[1])
  else
    echo 'Too many candidates!'
  endif
endfunction

let s:kind.action_table.dirdiff = {
      \ 'description' : ':DirDiff with the other candidate',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.dirdiff.func(candidates)
  if !exists(':DirDiff')
    echo 'DirDiff.vim is not installed.'
    return
  endif

  if len(a:candidates) != 2
    echo 'Candidates must be 2.'
  else
    " :DirDiff the other candidate.
    tabnew
    let t:title = 'DirDiff'
    execute 'DirDiff' unite#helper#get_candidate_directory(a:candidates[0])
          \ unite#helper#get_candidate_directory(a:candidates[1])
  endif
endfunction

" For grep.
let s:kind.action_table.grep = {
      \   'description': 'grep this file',
      \   'is_quit': 1,
      \   'is_invalidate_cache': 1,
      \   'is_selectable': 1,
      \   'is_start' : 1,
      \ }
function! s:kind.action_table.grep.func(candidates) "{{{
  call unite#start_script([
        \ ['grep', map(copy(a:candidates),
        \ 'string(substitute(v:val.action__path, "/$", "", "g"))'),
        \ ]], { 'no_quit' : 1, 'no_empty' : 1 })
endfunction "}}}

let s:kind.action_table.grep_directory = {
      \   'description': 'grep this directory',
      \   'is_quit': 1,
      \   'is_invalidate_cache': 1,
      \   'is_selectable': 1,
      \   'is_start' : 1,
      \ }
function! s:kind.action_table.grep_directory.func(candidates) "{{{
  call unite#start_script([
        \ ['grep', map(copy(a:candidates),
        \  'string(unite#helper#get_candidate_directory(v:val))'),
        \ ]], { 'no_quit' : 1, 'no_empty' : 1 })
endfunction "}}}
"}}}

function! s:execute_command(command, candidate) "{{{
  let dir = unite#util#path2directory(a:candidate.action__path)
  " Auto make directory.
  if dir !~ '^\a\+:' && !isdirectory(dir) && !unite#util#is_sudo()
        \ && unite#util#input_yesno(
        \       printf('"%s" does not exist. Create?', dir))
    call mkdir(dir, 'p')
  endif

  call unite#util#smart_execute_command(
        \ a:command, unite#util#substitute_path_separator(
        \   fnamemodify(a:candidate.action__path, ':~:.')))
endfunction"}}}

" For exrename
let s:kind.action_table.exrename = {
      \   'description': 'bulk rename files',
      \   'is_quit': 1,
      \   'is_invalidate_cache': 1,
      \   'is_selectable': 1,
      \ }
function! s:kind.action_table.exrename.func(candidates)
  let context = unite#get_context()
  let buffer_name = context.buffer_name
  if buffer_name ==# 'default'
    let buffer_name = 'unite'
  endif
  call unite#exrename#create_buffer(a:candidates, {
        \ 'buffer_name': buffer_name,
        \})
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
