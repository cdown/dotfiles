"=============================================================================
" FILE: matcher_project_ignore_files.vim
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

function! unite#filters#matcher_project_ignore_files#define() "{{{
  return s:matcher
endfunction"}}}

let s:matcher = {
      \ 'name' : 'matcher_project_ignore_files',
      \ 'description' : 'project ignore files matcher',
      \}

let s:cache_ignore_files = {}

function! s:matcher.filter(candidates, context) "{{{
  let path = a:context.path != '' ? a:context.path : getcwd()
  let project = unite#util#path2project_directory(path) . '/'
  if !has_key(a:context, 'filter__project_ignore_path')
        \ || a:context.filter__project_ignore_path !=# project
    let a:context.filter__project_ignore_path = project
    let [a:context.filter__project_ignore_patterns,
          \ a:context.filter__project_ignore_whites] =
          \ s:get_ignore_results(project)
  endif

  if empty(a:context.filter__project_ignore_patterns)
    return a:candidates
  endif

  return unite#filters#filter_patterns(a:candidates,
        \ a:context.filter__project_ignore_patterns,
        \ a:context.filter__project_ignore_whites)
endfunction"}}}

function! s:get_ignore_results(path) "{{{
  let globs = []
  let whites = []
  for ignore in [
        \ '.gitignore', '.hgignore', '.agignore', '.uniteignore',
        \ ]
    for f in split(globpath(a:path, '**/' . ignore), '\n')
      let _ = s:parse_ignore_file(
            \ fnamemodify(f, ':p'), fnamemodify(f, ':h'))
      let globs += _[0]
      let whites += _[1]
    endfor
  endfor

  return [unite#filters#globs2patterns(globs),
        \ unite#filters#globs2patterns(whites)]
endfunction"}}}

function! s:parse_ignore_file(file, prefix) "{{{
  " Note: whitelist "!glob" and "syntax: regexp" in .hgignore features is not
  " supported.
  let patterns = []
  let whites = []
  for line in filter(readfile(a:file),
        \ "v:val !~ '^\\s*$\\|\\s*syntax:\\|\\s*#'")
    if line[0] == '!'
      call add(whites, line[1:])
    else
      call add(patterns, line)
    endif
  endfor

  let func = "a:prefix.'/' . (stridx(v:val, '/') >= 0 ? '' : '**/') . v:val"
  return [map(patterns, func), map(whites, func)]
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
