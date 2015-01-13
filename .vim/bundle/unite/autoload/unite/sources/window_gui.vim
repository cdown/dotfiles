"=============================================================================
" FILE: window/gui.vim
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

function! unite#sources#window_gui#define() "{{{
  return executable('wmctrl') ? s:source : {}
endfunction"}}}

let s:source = {
      \ 'name' : 'window/gui',
      \ 'description' : 'candidates from GUI window list',
      \ 'syntax' : 'uniteSource__WindowGUI',
      \ 'hooks' : {},
      \ 'action_table' : {},
      \ 'alias_table': { 'edit' : 'rename' },
      \ 'default_action' : 'open',
      \}

function! s:source.hooks.on_syntax(args, context) "{{{
  syntax match uniteSource__WindowGUI_Class /\[\S\+\]/
        \ contained containedin=uniteSource__WindowGUI
  highlight default link uniteSource__WindowGUI_Class Type
endfunction"}}}
function! s:source.gather_candidates(args, context) "{{{
  let current = getpid()
  let _ = []
  let classes = []
  for line in split(unite#util#system('wmctrl -lpx'), '\n')
    let list = matchlist(line, '^\(\S\+\)\s\+\d\+\s\+\(\d\+\)\s\+'
          \ . '\(\S\+\)\s\+\S\+\s\+\(.*\)$')
    if len(list) < 6
      continue
    endif

    let [line, id, pid, class, title] = list[:4]

    " Skip current Vim and Desktop
    if pid != current && class !=# 'N/A'
          \ && class !=# 'desktop_window.Nautilus'
      call add(_, {
            \ 'id' : id,
            \ 'class' : class,
            \ 'title' : title,
            \ })
      call add(classes, len(class))
    endif
  endfor

  let max_class = max(classes) + 2
  return map(_, "{
            \ 'word' : v:val.class . ' ' . v:val.title,
            \ 'abbr' : printf('%-' . max_class . 's %s',
            \          '['.v:val.class.']', v:val.title),
            \ 'action__id' : v:val.id,
            \ 'action__title' : v:val.title,
            \ }")
endfunction"}}}
function! s:source.complete(args, context, arglead, cmdline, cursorpos) "{{{
  return ['no-current']
endfunction"}}}

" Actions "{{{
let s:source.action_table.open = {
      \ 'description' : 'move to this window',
      \ }
function! s:source.action_table.open.func(candidate) "{{{
  call unite#util#system(printf('wmctrl -i -a %s',
          \ a:candidate.action__id))
endfunction"}}}

let s:source.action_table.delete = {
      \ 'description' : 'delete windows',
      \ 'is_selectable' : 1,
      \ 'is_invalidate_cache' : 1,
      \ 'is_quit' : 0,
      \ }
function! s:source.action_table.delete.func(candidates) "{{{
  for candidate in a:candidates
    call unite#util#system(printf('wmctrl -i -c %s',
          \ candidate.action__id))
  endfor
  sleep 100m
endfunction"}}}

let s:source.action_table.rename = {
      \ 'description' : 'rename window title',
      \ 'is_invalidate_cache' : 1,
      \ 'is_quit' : 0,
      \ }
function! s:source.action_table.rename.func(candidate) "{{{
  let old_title = a:candidate.action__title
  let title = input(printf('New title: %s -> ', old_title), old_title)
  if title != '' && title !=# old_title
    call unite#util#system(printf('wmctrl -i -r %s -T %s',
          \ a:candidate.action__id, string(title)))
  endif
endfunction"}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
