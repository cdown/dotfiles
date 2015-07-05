" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see :help license

" let vimlparsers#splitargs_pat = '\v%(%(\\@1<!%(\\\\)*)@>)@<=\|'
let s:range_modifier = '(\s*[+-]+\s*\d*)?'
fun! vimlparsers#ParseRange(cmdline) " {{{
    let range = ""
    let cmdline = a:cmdline
    while len(cmdline)
	let cl = cmdline
	if cmdline =~ '^\s*%'
	    let range = matchstr(cmdline, '^\s*%\s*')
	    return [range, cmdline[len(range):], 0]
	elseif &cpoptions !~ '\*' && cmdline =~ '^\s*\*'
	    let range = matchstr(cmdline, '^\s*\*\s*')
	    return [range, cmdline[len(range):], 0]
	elseif cmdline =~ '^\s*\d'
	    let add = matchstr(cmdline, '\v^\s*\d+'.s:range_modifier)
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 1
	    " echom range
	elseif cmdline =~ '^\s*[-+]'
	    let add = matchstr(cmdline, '\v^\s*'.s:range_modifier)
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 2
	elseif cmdline =~ '^\.\s*'
	    let add = matchstr(cmdline, '\v^\s*\.'.s:range_modifier)
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 3
	    " echom range
	elseif cmdline =~ '^\s*\\[&/?]'
	    let add = matchstr(cmdline, '^\v\s*\\[/&?]'.s:range_modifier)
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 4
	    " echom range
	elseif cmdline =~ '^\s*[?/]'
	    let add = matchstr(cmdline, '^\v\s*[?/]@=')
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    let [char, pattern] = vimlparsers#ParsePattern(cmdline)
	    " echom cmdline.":".add.":".char.":".pattern
	    let range .= char . pattern . char
	    let cmdline = cmdline[len(pattern)+2:]
	    let add = matchstr(cmdline, '^\v'.s:range_modifier)
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 5
	    " echom range . "<F>".cmdline."<"
	elseif cmdline =~ '^\s*\$'
	    let add = matchstr(cmdline, '\v^\s*\$'.s:range_modifier)
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 6
	    " echom range
	elseif cmdline =~ '^\v[[:space:];,]+'  " yes you can do :1,^t;;; ,10# and it will work like :1,10#
	    let add = matchstr(cmdline,  '^\v[[:space:];,]+')
	    let range .= add
	    let cmdline = cmdline[len(add):]
	    " echom 7
	elseif cmdline =~ '^\v\s*[''`][a-zA-Z<>`'']'
	    let add = matchstr(cmdline, '^\v\s*[''`][a-zA-Z<>`'']') 
	    let range .= add
	    let cmdline = cmdline[len(add):]
	elseif cmdline =~ '^\s*\w'
	    return [range, cmdline, 0]
	endif
	if cl == cmdline
	    " Parser didn't make a step (so it falls into a loop)
	    " for example when there is no range, or for # command
	    return [range, cmdline, 1]
	endif
    endwhile
    return [range, cmdline, 0]
endfun " }}}

fun! vimlparsers#ParsePattern(line, ...) " {{{
    " Parse /pattern/ -> return ['/', 'pattern']
    " this is useful for g/pattern/ type command
    if a:0 >= 1
	let escape_char = a:1
    else
	let escape_char = '\'
    endif
    let char = a:line[0]
    let line = a:line[1:]
    let pattern = ''
    let escapes = 0
    for nchar in split(line, '\zs')
	if nchar == escape_char
	    let escapes += 1
	endif
	if nchar !=# char || (escapes % 2)
	    let pattern .= nchar
	else
	    break
	endif
	if nchar != escape_char
	    let escapes = 0
	endif
    endfor
    return [char, pattern]
endfun " }}}

fun! vimlparsers#ParseString(str)  "{{{
    let i = 0
    while i < len(a:str)
	let i += 1
	let c = a:str[i]
	if c != "'"
	    cont
	else
	    if a:str[i+1] == "'"
		let i += 1
		con
	    else
		break
	    endif
	endif
    endwhile
    return a:str[:i]
endfun  "}}}

let vimlparsers#cmd_decorators_pat = '^\v\C(:|\s)*('.
		\ 'sil%[ent]!?\s*|'.
		\ 'debug\s*|'.
		\ 'noswap%[file]\s*|'.
		\ '\d*verb%[ose]\s*'.
	    \ ')*\s*($|\S@=)'

let vimlparsers#s_cmd_pat = '^\v\C\s*('.
	    \ 'g%[lobal]\s*|'.
	    \ 'v%[global]\s*|'.
	    \ 'vim%[grep]\s*|'.
	    \ 'lv%[imgrep]\s*'.
	    \ ')($|\W@=)'
let vimlparsers#grep_cmd_pat = '^\v\C\s*('.
	    \ 'vim%[grep]\s*|'.
	    \ 'lv%[imgrep]\s*'.
	    \ ')($|\W@=)'

" s:CmdLineClass {{{
let s:CmdLineClass = {
	    \ 'decorator': '',
	    \ 'global': 0,
	    \ 'range': '',
	    \ 'cmd': '',
	    \ 'pattern': '',
	    \ 'args': '',
	    \ }
fun! s:CmdLineClass.Repr() dict
    return '<CmdLine: ' .self['decorator'].':'.self['range'].':'.self['cmd'].':'.self['pattern'].':'.self['args'].'>'
endfun
fun! s:CmdLineClass.Join() dict
    return self['decorator'].self['range'].self['cmd'].self['pattern'].self['args']
endfun  "}}}
" TODO :help function /{pattern}
" see :help :\bar (the list below does not include global and vglobal
" commands)
let vimlparsers#bar_cmd_pat = '^\v\C\s*('.
	    \ 'argdo!?|'.
	    \ 'au%[tocmd]|'.
	    \ 'bufdo!?|'.
	    \ 'com%[mand]|'.
	    \ 'cscope|'.
	    \ 'debug|'.
	    \ 'foldopen!?|'.
	    \ 'foldclose!?|'.
	    \ 'function!?|'.
	    \ 'h%[elp]|'.
	    \ 'helpf%[ind]|'.
	    \ 'lcscope|'.
	    \ 'make|'.
	    \ 'norm%[al]|'.
	    \ 'pe%[rl]|'.
	    \ 'perldo?|'.
	    \ 'promptf%[ind]|'.
	    \ 'promptr%[epl]|'.
	    \ 'pyf%[ile]|'.
	    \ 'py%[thon]|'.
	    \ 'reg%[isters]|'.
	    \ 'r%[ead]\s+!|'.
	    \ 'scscope|'.
	    \ 'sign|'.
	    \ 'tcl|'.
	    \ 'tcldo?|'.
	    \ 'tclf%[ile]|'.
	    \ 'windo|'.
	    \ 'w%[rite]\s+!|'.
	    \ 'helpg%[rep]|'.
	    \ 'lh%[elpgrep]|'.
	    \ '%(r%[ead]\s*)?\!.*'.
	\ ')\s*%(\W|$)@='

let vimlparsers#edit_cmd_pat = '^\v\C\s*('.
		\ 'e%[dit]!?|'.
		\ 'view?|'.
		\ 'r%[ead]|'.
		\ 'sp%[lit]!?|'.
		\ 'vs%[plit]!?|'.
		\ 'find?!?|'.
		\ 'sf%[ind]!?|'.
		\ 'sv%[iew]!?|'.
		\ 'new!?|'.
		\ 'vnew?!?|'.
		\ 'vi%[sual]!?|'.
		\ 'ar%[gs]|'.
		\ 'arge%[dit]!?|'.
		\ 'w[nN]%[ext]!?|'.
		\ 'wp%[revious]!?|'.
		\ 'sav%[eas]!?|'.
		\ 'wq!?|'.
		\ 'exi%[t]!?|'.
		\ 'tabe%[dit]'.
	    \ ')%($|\W@=)'
" :args command is not supported :args [++opt] [+cmd] {arglist}
" :write, :update commands are not supported: :w [++opt] >> {file}

let vimlparsers#fname_cmds_pat = '^\v\C\s*('.
		\ '%('.
		    \ 's?b%[uffer]!?|'.
		    \ 'bdelete!?|'.
		    \ 'bunload!?|'.
		    \ 'bw%[ipeout]!?'.
		\ ')'.
		\ '\s*%(\f|%(%(\\\\)*)@>\\[|\s])*'.
	    \ ')'

fun! vimlparsers#ParseCommandLine(cmdline, cmdtype)  "{{{
    " returns command line splitted by |
    let cmdlines = []
    let idx = 0
    let cmdl = copy(s:CmdLineClass)
    let global = 0
    let new_cmd = 1  " only after | or g command
    let fun = 0  " expect call <...> or let <...>
    let check_range = 1 " as above but it is reset on the begining, so it cannot be used later
    if a:cmdtype == '/' || a:cmdtype == '?'
	let cmdl.pattern = a:cmdline
	call add(cmdlines, cmdl)
	return cmdlines
    endif
    let cmdline = a:cmdline
    while !empty(cmdline)
	" echo 'cmdline: <'.cmdline.'>'
	if check_range == 1
	    let decorator = matchstr(cmdline, g:vimlparsers#cmd_decorators_pat)
	    let cmdline = cmdline[len(decorator):]
	    let cmdl.decorator = decorator
	    let [range, cmdline, error] = vimlparsers#ParseRange(cmdline)
	    let check_range = 0
	    let cmdl.range = range
	    let idx += len(range) + 1
	    let after_range = 1
	    " echo cmdl.Repr()
	    con
	else
	    let after_range = 0
	endif
	let match = matchstr(cmdline, g:vimlparsers#s_cmd_pat)
	if !empty(match) && !fun 
	    let global = (cmdline =~# '^\v\C\s*%(g%[lobal]|v%[global])\s*%($|\W@=)' ? 1 : 0)
	    let grep_cmd = cmdline =~# g:vimlparsers#grep_cmd_pat
	    let cmdl.global = global
	    let cmdl.cmd .= match
	    let idx += len(match)
	    let cmdline = cmdline[len(match):]
	    let [char, pat] = vimlparsers#ParsePattern(cmdline)
	    let cmdl.pattern .= char.pat
	    let d = len(char.pat)
	    let idx += d
	    let cmdline = cmdline[(d):]
	    if cmdline[0] == char
		let cmdl.pattern .= char
		let idx += 1
		let cmdline = cmdline[1:]
	    endif
	    if grep_cmd
		" parse vimgrep & lvimgrep arguments
		let match = matchstr(cmdline, '^\v([^|]|\\@1<=\|)*')
		let cmdl.args .= match
		let cmdline = cmdline[len(match):]
	    endif
	    if global
		call add(cmdlines, cmdl)
		let global = 0
		let cmdl = copy(s:CmdLineClass)
		let check_range = 1
	    endif
	    let idx += 1
	    let new_cmd = (global ? 1 : 0)
	    con
	endif
	let match = matchstr(cmdline, '^\v\C\s*s%[ubstitute]\s*($|\W@=)') 
	if !empty(match) && !fun
	    " echom "cmdline (sub): ".cmdline
	    let new_cmd = 0
	    let cmdl.cmd .= match
	    let d = len(match)
	    let idx += d
	    let cmdline = cmdline[(d):]
	    let [char, pat] = vimlparsers#ParsePattern(cmdline)
	    let cmdl.pattern .= char.pat
	    let d = len(char.pat)
	    let idx += d
	    let cmdline = cmdline[(d):]
	    let [char, pat] = vimlparsers#ParsePattern(cmdline)
	    let cmdl.pattern .= char
	    let cmdl.args .= pat
	    let d = len(char.pat)
	    let idx += d
	    " echom "cmdline (sub): ".cmdline
	    let cmdline = cmdline[(d):]
	    if cmdline[0] == char
		let idx += 1
		let cmdl.args .= char
		let cmdline = cmdline[1:]
		let flags = matchstr(cmdline, '^\C[\&cegiInp\#lr[:space:]]*')
		let cmdl.args .= flags
		let cmdline = cmdline[len(flags):]
	    endif
	    let idx += 1
	endif
	let matchlist = matchlist(cmdline, '^\v(ps%[earch]!?)(\s*\d*\s*)?(.*)')
	if !empty(matchlist)
	    let cmdl.cmd .= matchlist[1] . matchlist[2]
	    let cmdl.pattern = matchlist[3]
	    break
	endif
	let match = matchstr(cmdline, g:vimlparsers#bar_cmd_pat . '.*')
	if !empty(match) && new_cmd && !fun
	    let cmdl.cmd .= match
	    break
	endif
	let match = matchstr(cmdline, '^\C\v\s*se%[t]([^\|]|%(%(\\\\)*)@>\\\|)*')
	if !empty(match) && new_cmd && !fun
	    let cmdl.cmd .= match
	    let idx += len(match)
	    let cmdline = cmdline[len(match):]
	endif
	let match = matchstr(cmdline, g:vimlparsers#edit_cmd_pat)
	if !empty(match) && new_cmd && !fun
	    let match = matchstr(cmdline, '^\v\w+!?\s+'.
			\ '%('.
			    \ '\s*\+%([^[:space:]]|'.
				\ '%(%(%(\\\\)*)@>\\)@10<=\s'.
			    \ ')*|'.
			    \ '\s*%('.
				\ '[^|[:space:]]|'.
				\ '%(%(%(\\\\)*)@>\\)@10<=\|[|[:space:]]'.
			    \ ')*'.
			\ ')*')
	    let cmdl.cmd .= match
	    let idx += len(match)
	    let cmdline = cmdline[len(match):]
	endif
	let matches = matchlist(cmdline, '^\v\C(fu%[nction]\s+)(\/.*)')
	if !empty(matches) && new_cmd && !fun
	    let cmdl.cmd .= matches[1]
	    let cmdl.pattern = matches[2]
	    let idx = len(matches[1])
	    let cmdline = ''
	endif
	unlet matches
	let match = matchstr(cmdline, g:vimlparsers#fname_cmds_pat)
	if !empty(match) && !fun
	    let cmdl.cmd .= match
	    let idx += len(match)
	    let cmdline = cmdline[len(match):]
	endif
	let match = matchstr(cmdline, '^\v\C%(call|let|echo)($|\W@=)\s*')
	if !empty(match) && !fun
	    let cmdl.cmd .= match
	    let idx += len(match)
	    let cmdline = cmdline[len(match):]
	    let fun = 1
	endif
	if fun
	    let match = matchstr(cmdline, '^(\w:)?\w\+')
	else
	    let match = matchstr(cmdline, '^\w\+')
	endif
	if !empty(match)
	    if !empty(cmdl.pattern)
		let cmdl.args .= match
	    else
		let cmdl.cmd .= match
	    endif
	    let idx += len(match)
	    let cmdline = cmdline[len(match):]
	endif
	let c = cmdline[0]
	if c ==# '"'
	    let [char, str] = vimlparsers#ParsePattern(cmdline)
	    if !empty(cmdl.pattern)
		let cmdl.args .= char.str.char
	    else
		let cmdl.cmd .= char.str.char
	    endif
	    let d= len(char.str.char)
	    let idx += d + 1
	    let cmdline = cmdline[(d):]
	elseif c ==# "'"
	    let str = vimlparsers#ParseString(cmdline)
	    if !empty(cmdl.pattern)
		let cmdl.args .= str
	    else
		let cmdl.cmd .= str
	    endif
	    let d = len(str)
	    let idx += d + 1
	    let cmdline = cmdline[(d):]
	elseif c ==# "|"
	    call add(cmdlines, cmdl)
	    let cmdline = cmdline[1:]
	    let cmdl = copy(s:CmdLineClass)
	    let idx += 1
	    let check_range = 1
	    let new_cmd = 1
	    con
	else
	    if !empty(cmdl.pattern)
		let cmdl.args .= c
	    else
		let cmdl.cmd .= c
	    endif
	    let idx += 1
	    let cmdline = cmdline[1:]
	endif
	let new_cmd = 0
    endwhile
    call add(cmdlines, cmdl) 
    return cmdlines
endfun  "}}}
