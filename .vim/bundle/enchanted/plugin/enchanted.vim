" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see :help license

if !exists('g:VeryMagic')
    let g:VeryMagic = 1
endif
if !exists('g:VeryMagicSubstitute')
    let g:VeryMagicSubstitute = 0
endif
if !exists('g:VeryMagicGlobal')
    let g:VeryMagicGlobal = 0
endif
if !exists('g:VeryMagicVimGrep')
    let g:VeryMagicVimGrep = 0
endif
if !exists('g:VeryMagicRange')
    let g:VeryMagicRange = 0
endif
if !exists('g:VeryMagicSearchArg')
    let g:VeryMagicSearchArg = 0
endif
if !exists('g:VeryMagicFunction')
    let g:VeryMagicFunction = 0
endif
if !exists('g:VeryMagicHelpgrep')
    let g:VeryMagicHelpgrep = 0
endif
if !exists('g:VeryMagicEscapeBackslashesInSearchArg')
    " This is very experimental. It has to detect when to escape the pattern
    " to not double escape it.
    let g:VeryMagicEscapeBackslashesInSearchArg = 0
endif
if !exists('g:SortEditArgs')
    let g:SortEditArgs = 0
endif

let g:DetectVeryMagicPattern = '\v%(%(\\\\)*)@>\\v'  " or '^\\v\>'
let g:DetectVeryMagicBackslashEscapedPattern = '\v%(%(\\\\\\\\)*)@>\\\\v'  " or '^\\\\v\>'
" The default matches even number of backslashes followed by v.

fun! s:VeryMagicSearch(dispatcher)  "{{{
    " / and ? commands
    " a:dispatcher: is crdispatcher#CRDispatcher dict
    if !g:VeryMagic || !(a:dispatcher.cmdtype ==# '/' || a:dispatcher.cmdtype ==# '?')
	let a:dispatcher.state = 1
	return
    endif
    let cmd = a:dispatcher.cmd
    let cmdline = cmd.pattern
    let a:dispatcher.state = 1
    if !empty(cmdline) && cmdline[0] !=# '/' && cmdline !~# g:DetectVeryMagicPattern
	let cmdline = '\v'.cmdline
    endif
    let cmd.pattern = cmdline
    let [char, pattern] = vimlparsers#ParsePattern((a:dispatcher.cmdtype) . cmdline)
    let offset = cmdline[(len(pattern)+1):]
    " There can be more than one offset
    if offset =~ '\s*;\s*[?/]'
	let cmdline = cmdline[:len(pattern)]  " cut the offset
	let new_offset = ''
	let o_pat = '^\s*\v(\d+|[+-]\d*|[esb][+-]?\d*)'
	while !empty(offset)
	    let o = matchstr(offset, o_pat)
	    if !empty(o)
		let new_offset .= o
		let offset = offset[len(o):]
	    elseif offset =~ '\s*;\s*[?/]'
		let start = matchstr(offset, '\v\s*;\s*[?/]@=')  " ? or /
		let offset = offset[len(start):]
		let [char, pat] = vimlparsers#ParsePattern(offset)
		let pat_l = len(pat)
		let offset = offset[(pat_l+1):]
		let end = matchstr(offset, '[?/]\s*')  " empty string, ? or /
		let offset = offset[len(end):]
		if pat_l && pat !~# g:DetectVeryMagicPattern
		    let pat = '\v'.pat
		endif
		let new_offset .= start . char . pat . end
	    else
		let new_offset .= offset
		break
	    endif
	endwhile
	let cmd.pattern = cmdline.new_offset
    endif
    let g:VeryMagicLastSearchCmd = cmd.pattern
endfun
try
    call add(crdispatcher#CRDispatcher['callbacks'], function('s:VeryMagicSearch'))
catch /E121:/
    echohl ErrorMsg
    echom 'EnchantedVim Plugin: please install "https://github.com/coot/CRDispatcher".'
    echohl Normal
endtry  "}}}

fun! <SID>VeryMagicStar(searchforward, g)  "{{{
    " used to replace * and # normal commands
    " This keeps the search history clean (no no very magic patterns which
    " then would be missunderstood).  Another approach would be to use
    "	normal *
    " and only manipulate with the hisory, but this approach is more
    " consistent.
    let word = expand('<cword>')
    let pat = escape(word, '.?=@*+&()[]{}^$|/\~')
    if !a:g
	let pat = '<'.pat.'>'
    endif
    let pat = '\v'.pat
    if !a:searchforward
	" emulate vim's behaviour
	call search(pat, 'bsc')
	call search(pat, 'b')
    else
	call search(pat, 's')
    endif
    let g:VeryMagicLastSearchCmd = pat
    let @/ = pat
    call histadd('/', pat)
endfun

if g:VeryMagic
    " We make this two maps so that the search history contains very magic
    " patterns.
    nm <silent> * :call <SID>VeryMagicStar(1, 0)<CR>
    nm <silent> # :call <SID>VeryMagicStar(0, 0)<CR>
    " This map in general should not be necessary, unless isk contains
    " characters which needs to be escaped
    nm <silent> g* :call <SID>VeryMagicStar(1, 1)<CR>
    nm <silent> g# :call <SID>VeryMagicStar(0, 1)<CR>
endif  "}}}

let s:Range = copy(crdispatcher#CallbackClass)  "{{{
fun! s:Range.__transform_cmd__(dispatcher) dict  "{{{2
    if !g:VeryMagicRange || a:dispatcher.cmdtype !=# ':'
	return
    endif
    let a:dispatcher.state = 1
    let range = a:dispatcher.cmd.range
    let idx = 0
    let new_range = ''
    while idx < len(range)
	let char = range[idx]
	let rest = range[(idx):]
	if char ==# '/' || char ==# '?'
	    let [char, pattern] = vimlparsers#ParsePattern(rest)
	    let g:VeryMagicLastSearchCmd = pattern
	    let idx += len(pattern) + 1  " + 1 is added at the end
	    if pattern !~# g:DetectVeryMagicPattern
		let pattern = '\v' . pattern
	    endif
	    let new_range .= char . pattern . char
	else
	    let new_range .= char
	endif
	let idx += 1
    endwhile
    let a:dispatcher.cmd.range = new_range
endfun  "}}}2
try
    call add(crdispatcher#CRDispatcher['callbacks'], s:Range)
catch /E121:/
endtry  "}}}

let s:Substitute = copy(crdispatcher#CallbackClass)  "{{{
call s:Substitute.__init__(
	    \ 'g:VeryMagicSubstitute',
	    \ ':',
	    \ '^\C\v\s*s%[ubstitute]\s*$',
	    \ 2)
try
    call add(crdispatcher#CRDispatcher['callbacks'], s:Substitute)
catch /E121:/
endtry  "}}}

let s:VimGrep = copy(crdispatcher#CallbackClass)  "{{{
call s:VimGrep.__init__('g:VeryMagicVimGrep',
	    \ ':',
	    \ '^\C\v(\s*%(vim%[grep]|lv%[imgrep])\s*)$')
try
    call add(crdispatcher#CRDispatcher['callbacks'], s:VimGrep)
catch /E121:/
endtry  "}}}

let s:Function = copy(crdispatcher#CallbackClass)  "{{{
call s:Function.__init__('g:VeryMagicFunction',
	    \ ':',
	    \ '^\C\v\s*fu%[nction]\s*$')
try
    call add(crdispatcher#CRDispatcher['callbacks'], s:Function)
catch /E121:/
endtry  "}}}

let s:Global = copy(crdispatcher#CallbackClass)  "{{{
call s:Global.__init__(
	    \ 'g:VeryMagicGlobal',
	    \ ':',
	    \ '^\v(%(\s*g%[lobal]|v%[global])!?\s*)$')
fun! s:Global.__transform_args__(dispatcher, cmd_args)
    let disp = copy(a:dispatcher)
    let disp.state = 0
    return disp.dispatch(a:dispatcher.ctrl_f, a:cmd_args, a:dispatcher.cmdtype)
endfun
try
    call add(crdispatcher#CRDispatcher['callbacks'], s:Global)
catch /E121:/
endtry  "}}}

fun! s:SortEditArgs(dispatcher)  "{{{
    " Rewrite ":edit fname.txt +/pattern" into ":edit +/pattern fname.txt"
    " this works for all g:vimlparsers#edit_cmd_pat
    let cmd = a:dispatcher.cmd
    let c = cmd.cmd
    let match = matchstr(c, g:vimlparsers#edit_cmd_pat)
    if (!g:SortEditArgs) || a:dispatcher.cmdtype !=# ':' || empty(match)
	let a:dispatcher.state = 1
	return
    endif
    let c = c[len(match):]
    let _c = {
	\ 'cmd': match,
	\ 'fname': '',
	\ }
    while c !~ '^\s*$'
	let match = matchstr(c, '\v^\s*\+\/%(\S|%(%(%(\\\\)*)@>\\)@10<=\s)*')
	if !empty(match)
	    let c = c[len(match):]
	    let _c.cmd .= match
	    cont
	endif
	let match = matchstr(c, '\v^\s*\++%(\S|%(%(%(\\\\)*)@>\\)@10<=\s)*')
	if !empty(match)
	    let c = c[len(match):]
	    let _c.cmd .= match
	    cont
	endif
	let match = matchstr(c, '\v^\s*[^+](\S|%(%(%(\\\\)*)@>\\)@10<=\s)*')
	if !empty(match)
	    let c = c[len(match):]
	    let _c.fname .= match
	    cont
	endif
    endwhile
    let cmd.cmd = _c.cmd . _c.fname
endfun
try
    call add(crdispatcher#CRDispatcher['callbacks'], function('s:SortEditArgs'))
catch /E121:/
endtry  "}}}

fun! s:VeryMagicSearchArg(dispatcher)  "{{{
    " :edit +/pattern but also :view, :sview, :visual, :ex, :split, :vsplit, :new,
    " :vnew, :find, :sfind.
    if (!g:VeryMagicSearchArg && !g:VeryMagicEscapeBackslashesInSearchArg) || a:dispatcher.cmdtype !=# ':'
	let a:dispatcher.state = 2
	return
    endif
    let cmd = a:dispatcher.cmd
    let cmdline = cmd.cmd
    let pat = g:vimlparsers#edit_cmd_pat . 
		\ '(\s.{-})'.
		\ '(\s@1<=\+/\S@=)'.
		\ '(%(\S|%(%(%(%(\\\\)*)@>)\\)@10<=\s)+)'.
		\ '(.*)'
    let matches = matchlist(cmdline, pat)
    if !empty(matches)
	let a:dispatcher.state = 1
	let pat = matches[4]
	if g:VeryMagicEscapeBackslashesInSearchArg && pat =~# '\v\\@1<!\\%([^\\]|$)'
	    " TODO: it is not easy find a regex which detects if the pattern
	    " should be escaped.  The current pattern matches if there is
	    " a single '\' and this will not work well when the user wants to
	    " escape multiple bacsklashes.
	    let pat = escape(pat, '\')
	endif
	if g:VeryMagicSearchArg && pat !~# g:DetectVeryMagicBackslashEscapedPattern
	    let pat = '\\v' . pat
	endif
	let cmd.cmd = matches[1] . matches[2] . matches[3] . pat . matches[5]
    endif
endfun
try
    call add(crdispatcher#CRDispatcher['callbacks'], function('s:VeryMagicSearchArg'))
catch /E121:/
endtry  "}}}

fun! s:VeryMagicHelpgrep(dispatcher)  "{{{
    if (!g:VeryMagicHelpgrep) || a:dispatcher.cmdtype !=# ':'
	let a:dispatcher.state = 2
	return
    endif
    let cmd = a:dispatcher.cmd
    let cm = cmd.cmd
    let matches = matchlist(cm, '^\C\v(%(helpg%[rep]|lh%[elpgrep])\s*)(\S.*)') 
    if !empty(matches)
	let l:c = matches[1]
	let l:p = matches[2]
	if l:p !~# g:DetectVeryMagicPattern
	    let cm = l:c.'\v'.l:p
	endif
    endif
    let cmd.cmd = l:cm
endfun
try
    call add(crdispatcher#CRDispatcher['callbacks'], function('s:VeryMagicHelpgrep'))
catch /E121:/
endtry  "}}}
