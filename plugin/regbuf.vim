" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_regbuf') && g:loaded_regbuf
    finish
endif
let g:loaded_regbuf = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

if !exists('g:regbuf_debug')
    let g:regbuf_debug = 0
endif
if !exists('g:regbuf_open_command')
    let g:regbuf_open_command = 'new'
endif
if !exists('g:regbuf_no_default_keymappings')
    let g:regbuf_no_default_keymappings = 0
endif
if !exists('g:regbuf_no_default_edit_autocmd')
    let g:regbuf_no_default_edit_autocmd = 0
endif


command!
\   -bar -nargs=*
\   RegbufOpen
\   call regbuf#open(<f-args>)


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
