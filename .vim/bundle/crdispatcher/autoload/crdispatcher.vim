" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see :help license

let crdispatcher#CRDispatcher = {
	    \ 'callbacks': [],
	    \ 'state': 0
	    \ }
" each call callback is called with part of the command line. Command line is
" split by "|".  Each callback has access to crdispatcher#CRDispatcher and can
" change its state: 0 (pattern has not matched, in this case next cmdline
" fragrment will be appended and the callback will be retried), 1 (go to next
" fragment), 2 (go to next callback).
fun! crdispatcher#CRDispatcher.dispatch(...) dict "{{{
    if a:0 >= 1
	let self.ctrl_f = a:1
    else
	let self.ctrl_f = 0
    endif
    if a:0 >= 2
	let self.cmdline_orig = a:2
    else
	let self.cmdline_orig = getcmdline()
    endif
    if a:0 >= 3
	let self.cmdtype = a:3
    else
	let self.cmdtype = getcmdtype()
    endif
    let self.line = self.cmdline_orig
    let self.cmds = vimlparsers#ParseCommandLine(self.cmdline_orig, self.cmdtype)
    let cidx = 0
    let clen = len(self.callbacks)
    while cidx < clen
	let F = self.callbacks[cidx]
	let cidx += 1
	let self.idx = -1
	while self.idx < len(self.cmds) - 1
	    let self.state = 0
	    let self.idx += 1
	    let idx = self.idx
	    let self.cmd = self.cmds[idx]
	    " every callback has accass to whole self and can change
	    " self.cmdline (and self.range) and should set self.state
	    if type(F) == 4
		call F.__transform_cmd__(self)
	    elseif type(F) == 2
		call F(self)
	    endif
	    if self.state == 2
		" slicing in VimL does not raise exceptions [][100:] is []
		break
	    elseif self.state == 3
		break
	    endif
	endwhile
	unlet F
    endwhile
    let cmdline = ''
    let clen = len(self.cmds)
    for idx in range(clen)
	let cmd = self.cmds[idx]
	let cmdl = cmd.Join()
	let cmdline .= cmdl
	if !cmd.global && idx != clen - 1
	    let cmdline .= '|'
	endif
    endfor
    return cmdline
endfun "}}}

let crdispatcher#CallbackClass = {}
fun! crdispatcher#CallbackClass.__init__(vname, cmdtype, pattern, ...) dict  "{{{
    let self.variableName = a:vname
    let self.cmdtype = a:cmdtype
    let self.pattern = a:pattern
    if a:0 >= 1
	let self.tr = a:1
    else
	let self.tr = 1
    endif
endfun  "}}}
fun! crdispatcher#CallbackClass.__transform_args__(current_dispatcher, cmd_args) dict  "{{{
    " This callback is used only be g command to transform patterns hidden in
    " commands in its argument part: g/\vpat1/s/pat2/\U&\E/ -> s/\vpat2/...
    return a:cmd_args
endfun  "}}}
fun! crdispatcher#CallbackClass.__transform_cmd__(dispatcher) dict  "{{{
    if !{self.variableName} || a:dispatcher.cmdtype !=# self.cmdtype
	let a:dispatcher.state = 1
	return
    endif
    let matched = a:dispatcher.cmd.cmd =~# self.pattern
    if matched
	let a:dispatcher.state = 1
	let cmd = a:dispatcher.cmd
	let cmd.args = self.__transform_args__(a:dispatcher, cmd.args)
	let pat = cmd.pattern
	let mlist = matchlist(pat, '\v^(\s*)(.{-})(\s*)$')
	let pat = mlist[2]
	let pat_len = len(pat)
	if cmd.cmd =~# '\v^fu%[nction]\s*$'
	    let char_b = pat[0]
	    let char_e = ''
	    let pat_len -= 1
	    let pat = pat[1:]
	elseif pat[0] ==# pat[len(pat)-1]
	    let pat_len -= 2
	    let char_b = pat[0]
	    let char_e = char_b
	    let pat = pat[1:len(pat)-2]
	else
	    let char_b = ''
	    let char_e = ''
	endif
	if pat_len > 0 && pat !~# g:DetectVeryMagicPattern
	    let cmd.pattern = mlist[1].char_b.'\v'.pat.char_e.mlist[3]
	endif
	let a:dispatcher.cmd = cmd
	let a:dispatcher.cmdline = cmd.Join()
    endif
endfun  "}}}
