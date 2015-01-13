"=============================================================================
" FILE: command.vim
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

function! unite#kinds#command#define() "{{{
  return s:kind
endfunction"}}}

let s:kind = {
      \ 'name' : 'command',
      \ 'default_action' : 'execute',
      \ 'action_table': {},
      \ 'alias_table' : { 'ex' : 'nop' },
      \}

" Actions "{{{
let s:kind.action_table.execute = {
      \ 'description' : 'execute command',
      \ 'is_selectable' : 1,
      \ }
function! s:kind.action_table.execute.func(candidates) "{{{
  for candidate in a:candidates
    if get(candidate, 'action__command_args', '0') !=# '0'
      " Use edit action
      call s:kind.action_table.edit.func(candidate)
      continue
    endif

    let command = candidate.action__command
    let type = get(candidate, 'action__type', ':')
    if get(candidate, 'action__histadd', 0)
      call s:add_history(type, command)
    endif
    call s:execute_command(type . command)
  endfor
endfunction"}}}
let s:kind.action_table.edit = {
      \ 'description' : 'edit command',
      \ }
function! s:kind.action_table.edit.func(candidate) "{{{
  if has_key(a:candidate, 'action__description')
    " Print description.

    " For function.
    " let prototype_name = matchstr(a:candidate.action__description,
    "       \'\%(<[sS][iI][dD]>\|[sSgGbBwWtTlL]:\)\='
    "       \'\%(\i\|[#.]\|{.\{-1,}}\)*\s*(\ze\%([^(]\|(.\{-})\)*$')
    let prototype_name = matchstr(a:candidate.action__description,
          \'\<\%(\d\+\)\?\zs\h\w*\ze!\?\|'
          \'\<\%([[:digit:],[:space:]$''<>]\+\)\?\zs\h\w*\ze/.*')
    echon ':'
    echohl Identifier | echon prototype_name | echohl None
    if prototype_name != a:candidate.action__description
      echon substitute(a:candidate.action__description[
            \ len(prototype_name) :], '^\s\+', ' ', '')
    endif
  endif

  let command = input(':', a:candidate.action__command, 'command')
  if command != ''
    let type = get(a:candidate, 'action__type', ':')
    if get(a:candidate, 'action__histadd', 0)
      call s:add_history(type, command)
    endif
    call s:execute_command(command)
  endif
endfunction"}}}
"}}}
function! s:add_history(type, command) "{{{
  call histadd(a:type, a:command)
  if a:type ==# '/'
    let @/ = a:command
  endif
endfunction"}}}
function! s:execute_command(command) "{{{
  let temp = tempname()
  try
    call writefile([a:command], temp)
    execute 'source' fnameescape(temp)
  catch /E486/
    " Ignore search pattern error.
  finally
    if filereadable(temp)
      call delete(temp)
    endif
  endtry
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
