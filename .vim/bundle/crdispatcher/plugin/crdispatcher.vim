" Author: Marcin Szamotulski
" Email:  mszamot [AT] gmail [DOT] com
" License: vim-license, see :help license

let g:CRDispatcher = crdispatcher#CRDispatcher
fun! CRDispatch()
    return g:CRDispatcher.dispatch()
endfun
cno <C-M> <CR>
" When g: scope is missing, 'debug-mode' complains that the variable does not
" exists.
cno <Plug>CRDispatch <C-\>eg:CRDispatcher.dispatch()<CR><CR>
" Mod out 'debug-mode' to prevent recursive loop when deugging the plugin
" itself.
cm <expr> <CR> index(['>', '=', '@', ''], getcmdtype()) != -1 ? '<CR>' :  '<Plug>CRDispatch'
" Clever <c-f> fix:
cno <c-f> <C-\>eCRDispatcher.dispatch(1)<CR><c-f>
