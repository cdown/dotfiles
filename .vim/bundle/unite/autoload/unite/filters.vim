"=============================================================================
" FILE: filters.vim
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

" filter() for matchers.
function! unite#filters#filter_matcher(list, expr, context) "{{{
  if a:context.unite__max_candidates <= 0
        \ || a:expr == ''
        \ || !a:context.unite__is_interactive
        \ || len(a:context.input_list) > 1

    return a:expr == '' ? a:list :
          \ (a:expr ==# 'if_lua') ?
          \   unite#filters#lua_matcher(
          \      a:list, a:context, &ignorecase) :
          \ (a:expr ==# 'if_lua_fuzzy') ?
          \   unite#filters#lua_fuzzy_matcher(
          \      a:list, a:context, &ignorecase) :
          \ filter(a:list, a:expr)
  endif

  let _ = []
  let len = 0

  let max = a:context.unite__max_candidates * 5
  let offset = max*4
  for cnt in range(0, len(a:list) / offset)
    let list = a:list[cnt*offset : cnt*offset + offset]
    let list =
          \ (a:expr ==# 'if_lua') ?
          \   unite#filters#lua_matcher(list, a:context, &ignorecase) :
          \ (a:expr ==# 'if_lua_fuzzy') ?
          \   unite#filters#lua_fuzzy_matcher(list, a:context, &ignorecase) :
          \ filter(list, a:expr)
    let len += len(list)
    let _ += list

    if len >= max
      break
    endif
  endfor

  return _[: max]
endfunction"}}}
function! unite#filters#lua_matcher(candidates, context, ignorecase) "{{{
  if !has('lua')
    return []
  endif

  let input = substitute(a:context.input, '\\ ', ' ', 'g')
  let input = substitute(input, '\\\(.\)', '\1', 'g')
  if a:ignorecase
    let input = tolower(input)
  endif

  lua << EOF
do
  local input = vim.eval('input')
  local candidates = vim.eval('a:candidates')
  if (vim.eval('a:ignorecase') ~= 0) then
    for i = #candidates-1, 0, -1 do
      if (string.find(string.lower(candidates[i].word), input, 1, true) == nil) then
        candidates[i] = nil
      end
    end
  else
    for i = #candidates-1, 0, -1 do
      if (string.find(candidates[i].word, input, 1, true) == nil) then
        candidates[i] = nil
      end
    end
  end
end
EOF

  return a:candidates
endfunction"}}}
function! unite#filters#lua_fuzzy_matcher(candidates, context, ignorecase) "{{{
  if !has('lua')
    return []
  endif

  lua << EOF
do
  local pattern = vim.eval('unite#filters#fuzzy_escape(a:context.input)')
  local input = vim.eval('a:context.input')
  local candidates = vim.eval('a:candidates')
  if vim.eval('a:ignorecase') ~= 0 then
    pattern = string.lower(pattern)
    input = string.lower(input)
    for i = #candidates-1, 0, -1 do
      local word = string.lower(candidates[i].word)
      if string.find(word, pattern, 1) == nil then
        candidates[i] = nil
      end
    end
  else
    for i = #candidates-1, 0, -1 do
      local word = candidates[i].word
      if string.find(word, pattern, 1) == nil then
        candidates[i] = nil
      end
    end
  end
end
EOF

  return a:candidates
endfunction"}}}

function! unite#filters#fuzzy_escape(string) "{{{
  " Escape string for lua regexp.
  let [head, input] = unite#filters#matcher_fuzzy#get_fuzzy_input(
        \ unite#filters#escape(a:string))
  return head . substitute(input,
        \ '\%([[:alnum:]_/-]\|%.\)\ze.', '\0.-', 'g')
endfunction"}}}

function! unite#filters#escape(string) "{{{
  " Escape string for lua regexp.
  return substitute(substitute(substitute(substitute(a:string,
        \ '\\ ', ' ', 'g'),
        \ '[%\[\]().+?^$-]', '%\0', 'g'),
        \ '\*\@<!\*\*\@!', '.*', 'g'),
        \ '\*\*\+', '.*', 'g')
endfunction"}}}

function! unite#filters#lua_filter_head(candidates, input) "{{{
lua << EOF
do
  local input = vim.eval('tolower(a:input)')
  local candidates = vim.eval('a:candidates')
  for i = #candidates-1, 0, -1 do
    local word = candidates[i].action__path
        or candidates[i].word
    if string.find(string.lower(word), input, 1, true) ~= 1 then
      candidates[i] = nil
    end
  end
end
EOF

  return a:candidates
endfunction"}}}

function! unite#filters#vim_filter_head(candidates, input) "{{{
  let input = tolower(a:input)
  return filter(a:candidates,
        \ "stridx(tolower(get(v:val, 'action__path',
        \      v:val.word)), input) == 0")
endfunction"}}}

function! unite#filters#vim_filter_pattern(candidates, pattern) "{{{
  return filter(a:candidates,
        \ "get(v:val, 'action__path', v:val.word) !~? a:pattern")
endfunction"}}}

function! unite#filters#filter_patterns(candidates, patterns, whites) "{{{
  return unite#util#has_lua()?
          \ unite#filters#lua_filter_patterns(
          \   a:candidates, a:patterns, a:whites) :
          \ unite#filters#vim_filter_patterns(
          \   a:candidates, a:patterns, a:whites)
endfunction"}}}
function! unite#filters#lua_filter_patterns(candidates, patterns, whites) "{{{
lua << EOF
do
  local patterns = vim.eval('a:patterns')
  local whites = vim.eval('a:whites')
  local candidates = vim.eval('a:candidates')
  for i = #candidates-1, 0, -1 do
    local word = string.lower(candidates[i].action__path
        or candidates[i].word)
    for j = #patterns-1, 0, -1 do
      if string.find(word, patterns[j]) then
        local match = nil
        -- Search from whites
        for k = #whites-1, 0, -1 do
          if string.find(word, whites[k]) then
            match = k
            break
          end
        end

        if match == nil then
          candidates[i] = nil
        end
      end
    end
  end
end
EOF

  return a:candidates
endfunction"}}}
function! unite#filters#vim_filter_patterns(candidates, patterns, whites) "{{{
  let pattern = join(a:patterns, '\|')
  let white = join(a:whites, '\|')
  return filter(a:candidates,
        \ "get(v:val, 'action__path', v:val.word) !~? pattern
        \  || get(v:val, 'action__path', v:val.word) =~? white")
endfunction"}}}

function! unite#filters#globs2patterns(globs) "{{{
  return unite#util#has_lua() ?
          \ unite#filters#globs2lua_patterns(a:globs) :
          \ unite#filters#globs2vim_patterns(a:globs)
endfunction"}}}
function! unite#filters#globs2vim_patterns(globs) "{{{
  let patterns = []
  for glob in a:globs
    if glob !~ '^/'
      let glob = '/' . glob
    endif
    let glob = escape(glob, '~.^$')
    let glob = substitute(glob, '//', '/', 'g')
    let glob = substitute(glob, '\*\@<!\*\*\@!', '[^/]*', 'g')
    let glob = substitute(glob, '\\\@<!\*\*\+', '.*', 'g')
    let glob = substitute(glob, '\\\@<!?', '[^/]', 'g')
    let glob .= '$'
    call add(patterns, glob)
  endfor

  return patterns
endfunction"}}}
function! unite#filters#globs2lua_patterns(globs) "{{{
  let patterns = []
  for glob in a:globs
    if glob !~ '^/'
      let glob = '/' . glob
    endif
    let glob = tolower(glob)
    let glob = substitute(glob, '//', '/', 'g')
    let glob = substitute(glob, '[%().+^$-]', '%\0', 'g')
    let glob = substitute(glob, '\*\@<!\*\*\@!', '[^/]*', 'g')
    let glob = substitute(glob, '\\\@<!\*\*\+', '.*', 'g')
    let glob = substitute(glob, '\\\@<!?', '[^/]', 'g')
    let glob .= '$'
    call add(patterns, glob)
  endfor

  return patterns
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
