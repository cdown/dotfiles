"=============================================================================
" FILE: handlers.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
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

function! unite#handlers#_on_insert_enter()  "{{{
  if &filetype !=# 'unite'
    return
  endif

  setlocal modifiable

  let unite = unite#get_current_unite()
  let unite.is_insert = 1

  if unite.prompt_linenr != 0
    return
  endif

  " Restore prompt
  let unite.prompt_linenr = unite.init_prompt_linenr
  call append((unite.context.prompt_direction ==# 'below' ?
        \ '$' : 0), '')
  call unite#view#_redraw_prompt()
endfunction"}}}
function! unite#handlers#_on_insert_leave()  "{{{
  let unite = unite#get_current_unite()

  if line('.') != unite.prompt_linenr
    call cursor(0, 1)
  endif

  let unite.is_insert = 0
  let unite.context.input = unite#helper#get_input()

  if &filetype ==# 'unite'
    setlocal nomodifiable
  endif
endfunction"}}}
function! unite#handlers#_on_cursor_hold_i()  "{{{
  let unite = unite#get_current_unite()

  call unite#view#_change_highlight()

  if unite.max_source_candidates > unite.redraw_hold_candidates
    call s:check_redraw()
  endif

  if unite.is_async && &l:modifiable
    " Ignore key sequences.
    call feedkeys("a\<BS>", 'n')
    " call feedkeys("\<C-r>\<ESC>", 'n')
  endif
endfunction"}}}
function! unite#handlers#_on_cursor_moved_i()  "{{{
  let unite = unite#get_current_unite()
  let prompt_linenr = unite.prompt_linenr

  if unite.max_source_candidates <= unite.redraw_hold_candidates
    call s:check_redraw()
  endif

  " Prompt check.
  if line('.') == prompt_linenr && col('.') <= 1
    startinsert!
  endif
endfunction"}}}
function! unite#handlers#_on_text_changed()  "{{{
  let unite = unite#get_current_unite()
  if unite#helper#get_input(1) !=# unite.last_input
    call s:check_redraw()
  endif
endfunction"}}}
function! unite#handlers#_on_bufwin_enter(bufnr)  "{{{
  silent! let unite = getbufvar(a:bufnr, 'unite')
  if type(unite) != type({})
        \ || bufwinnr(a:bufnr) < 1
    return
  endif

  if bufwinnr(a:bufnr) != winnr()
    let winnr = winnr()
    execute bufwinnr(a:bufnr) 'wincmd w'
  endif

  call unite#handlers#_save_updatetime()

  call s:restore_statusline()

  if unite.context.split && winnr('$') != 1
    call unite#view#_resize_window()
  endif

  setlocal nomodified

  if exists('winnr')
    execute winnr.'wincmd w'
  endif

  call unite#init#_tab_variables()
  let t:unite.last_unite_bufnr = a:bufnr
endfunction"}}}
function! unite#handlers#_on_cursor_hold()  "{{{
  let is_async = 0

  call s:restore_statusline()

  if &filetype ==# 'unite'
    " Redraw.
    call unite#redraw()

    let unite = unite#get_current_unite()
    let is_async = unite.is_async

    if !unite.is_async && unite.context.auto_quit
      call unite#force_quit_session()
    endif
  else
    " Search other unite window.
    for winnr in filter(range(1, winnr('$')),
          \ "getbufvar(winbufnr(v:val), '&filetype') ==# 'unite'")
      let unite = getbufvar(winbufnr(winnr), 'unite')
      if unite.is_async
        " Redraw unite buffer.
        call unite#redraw(winnr)

        let is_async = unite.is_async
      endif
    endfor
  endif

  if is_async
    " Ignore key sequences.
    call feedkeys("g\<ESC>", 'n')
  endif
endfunction"}}}
function! unite#handlers#_on_cursor_moved()  "{{{
  if &filetype !=# 'unite'
    return
  endif

  let unite = unite#get_current_unite()
  let prompt_linenr = unite.prompt_linenr
  let context = unite.context

  let &l:modifiable =
        \ line('.') == prompt_linenr && col('.') >= 1

  if line('.') == 1
    nnoremap <silent><buffer> <Plug>(unite_loop_cursor_up)
          \ :call unite#mappings#loop_cursor_up('n')<CR>
    nnoremap <silent><buffer> <Plug>(unite_skip_cursor_up)
          \ :call unite#mappings#loop_cursor_up('n')<CR>
    inoremap <silent><buffer> <Plug>(unite_select_previous_line)
          \ <ESC>:call unite#mappings#loop_cursor_up('i')<CR>
    inoremap <silent><buffer> <Plug>(unite_skip_previous_line)
          \ <ESC>:call unite#mappings#loop_cursor_up('i')<CR>

    call s:cursor_down()
  elseif line('.') == line('$')
    nnoremap <silent><buffer> <Plug>(unite_loop_cursor_down)
          \ :call unite#mappings#loop_cursor_down('n')<CR>
    nnoremap <silent><buffer> <Plug>(unite_skip_cursor_down)
          \ :call unite#mappings#loop_cursor_down('n')<CR>
    inoremap <silent><buffer> <Plug>(unite_select_next_line)
          \ <ESC>:call unite#mappings#loop_cursor_down('i')<CR>
    inoremap <silent><buffer> <Plug>(unite_skip_next_line)
          \ <ESC>:call unite#mappings#loop_cursor_down('i')<CR>

    call s:cursor_up()
  else
    call s:cursor_up()
    call s:cursor_down()
  endif

  if exists('b:current_syntax')
    call unite#view#_clear_match()

    let is_prompt = (prompt_linenr == 0 &&
          \ (context.prompt_direction == 'below'
          \   && line('.') == line('$') || line('.') == 1))
          \ || line('.') == prompt_linenr
    if is_prompt || mode('.') == 'i' || unite.is_async
          \ || abs(line('.') - unite.prev_line) != 1
          \ || split(reltimestr(reltime(unite.cursor_line_time)))[0]
          \    > string(context.cursor_line_time)
      call unite#view#_set_cursor_line()
    endif

    let unite.cursor_line_time = reltime()
    let unite.prev_line = line('.')
  endif

  if context.auto_preview
    call unite#view#_do_auto_preview()
  endif
  if context.auto_highlight
    call unite#view#_do_auto_highlight()
  endif

  call s:restore_statusline()

  " Check lines. "{{{
  if !context.auto_resize &&
        \ winheight(0) < line('$') && line('.') + winheight(0) < line('$')
    return
  endif

  let height =
        \ (!unite.context.split
        \  || unite.context.winheight == 0) ?
        \ winheight(0) : unite.context.winheight
  let candidates = unite#candidates#_gather_pos(height)
  if !context.auto_resize && empty(candidates)
    " Nothing.
    return
  endif

  call unite#view#_resize_window()

  let modifiable_save = &l:modifiable
  try
    setlocal modifiable
    let pos = getpos('.')
    let lines = unite#view#_convert_lines(candidates)
    silent! call append('$', lines)
  finally
    let &l:modifiable = l:modifiable_save
  endtry

  let context = unite.context
  let unite.current_candidates += candidates

  if pos != getpos('.')
    call setpos('.', pos)
  endif"}}}
endfunction"}}}
function! unite#handlers#_on_buf_unload(bufname)  "{{{
  call unite#view#_clear_match()

  " Save unite value.
  silent! let unite = getbufvar(a:bufname, 'unite')
  if type(unite) != type({})
    " Invalid unite.
    return
  endif

  if &l:statusline == unite#get_current_unite().statusline
    " Restore statusline.
    let &l:statusline = &g:statusline
  endif

  if unite.is_finalized
    return
  endif

  " Restore options.
  if has_key(unite, 'redrawtime_save')
    let &redrawtime = unite.redrawtime_save
  endif
  let &sidescrolloff = unite.sidescrolloff_save

  call unite#handlers#_restore_updatetime()

  " Call finalize functions.
  call unite#helper#call_hook(unite#loaded_sources_list(), 'on_close')
  let unite.is_finalized = 1
endfunction"}}}
function! unite#handlers#_on_insert_char_pre()  "{{{
  let prompt_linenr = unite#get_current_unite().prompt_linenr

  if line('.') == prompt_linenr
    return
  endif

  call cursor(prompt_linenr, 0)
  startinsert!
  call unite#handlers#_on_cursor_moved()
endfunction"}}}

function! unite#handlers#_save_updatetime()  "{{{
  let unite = unite#get_current_unite()

  if unite.is_async && unite.context.update_time > 0
        \ && &updatetime > unite.context.update_time
    let unite.update_time_save = &updatetime
    let &updatetime = unite.context.update_time
  endif
endfunction"}}}
function! unite#handlers#_restore_updatetime()  "{{{
  let unite = unite#get_current_unite()

  if !has_key(unite, 'update_time_save')
    return
  endif

  if unite.context.update_time > 0
        \ && &updatetime < unite.update_time_save
    let &updatetime = unite.update_time_save
  endif
endfunction"}}}
function! s:restore_statusline()  "{{{
  if &filetype !=# 'unite' || !g:unite_force_overwrite_statusline
    return
  endif

  let unite = unite#get_current_unite()

  if &l:statusline != unite.statusline
    " Restore statusline.
    let &l:statusline = unite.statusline
  endif
endfunction"}}}

function! s:check_redraw() "{{{
  let unite = unite#get_current_unite()
  let prompt_linenr = unite.prompt_linenr
  if line('.') == prompt_linenr || unite.context.is_redraw
    " Redraw.
    call unite#redraw()
  endif
endfunction"}}}

function! s:cursor_up() "{{{
  nnoremap <expr><buffer> <Plug>(unite_loop_cursor_up)
        \ unite#mappings#cursor_up(0)
  nnoremap <expr><buffer> <Plug>(unite_skip_cursor_up)
        \ unite#mappings#cursor_up(1)
  inoremap <expr><buffer> <Plug>(unite_select_previous_line)
        \ unite#mappings#cursor_up(0)
  inoremap <expr><buffer> <Plug>(unite_skip_previous_line)
        \ unite#mappings#cursor_up(1)
endfunction"}}}
function! s:cursor_down() "{{{
  nnoremap <expr><buffer> <Plug>(unite_loop_cursor_down)
        \ unite#mappings#cursor_down(0)
  nnoremap <expr><buffer> <Plug>(unite_skip_cursor_down)
        \ unite#mappings#cursor_down(1)
  inoremap <expr><buffer> <Plug>(unite_select_next_line)
        \ unite#mappings#cursor_down(0)
  inoremap <expr><buffer> <Plug>(unite_skip_next_line)
        \ unite#mappings#cursor_down(1)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
