" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



" Variables
let s:INVALID_REGISTER = -1
lockvar s:INVALID_REGISTER



function! regbuf#open(...) "{{{
    call s:create_buffer('regbuf:registers', g:regbuf_open_command, 'nofile')

    call s:write_registers()

    if !g:regbuf_no_default_autocmd
        augroup regbuf
            autocmd!
            autocmd CursorMoved <buffer> call s:preview_register()
        augroup END
    endif

    nnoremap <silent><buffer> <Plug>(regbuf-yank)  :<C-u>call <SID>buf_yank()<CR>
    nnoremap <silent><buffer> <Plug>(regbuf-paste) :<C-u>call <SID>buf_paste()<CR>
    nnoremap <silent><buffer> <Plug>(regbuf-edit)  :<C-u>call <SID>buf_edit()<CR>
    nnoremap <silent><buffer> <Plug>(regbuf-close)  :<C-u>close<CR>
    if !g:regbuf_no_default_keymappings
        nmap <buffer> <LocalLeader>y <Plug>(regbuf-yank)
        nmap <buffer> <LocalLeader>p <Plug>(regbuf-paste)
        nmap <buffer> <LocalLeader>e <Plug>(regbuf-edit)

        nmap <buffer> <CR>      <Plug>(regbuf-edit)
        nmap <buffer> q         <Plug>(regbuf-close)
        nmap <buffer> <Esc>     <Plug>(regbuf-close)
    endif

    setlocal nomodifiable
    setfiletype regbuf
endfunction "}}}
function! s:write_registers() "{{{
    let save_lang = v:lang
    lang messages C
    try
        redir => output
            silent registers
        redir END
    finally
        execute 'lang messages' save_lang
    endtry
    let lines = split(output, '\n')
    call remove(lines, 0)    " First line must be "--- Registers ---"
    call setline(1, lines)
endfunction "}}}

function! s:buf_yank() "{{{
    let regname = s:get_regname_on_cursor()
    if regname ==# s:INVALID_REGISTER
        return
    endif
    let [value, type] = [getreg(regname, 1), getregtype(regname)]
    call setreg('"', value, type)
endfunction "}}}

function! s:buf_paste() "{{{
    let regname = s:get_regname_on_cursor()
    if regname ==# s:INVALID_REGISTER
        return
    endif
    let [value, type] = [getreg('"', 1), getregtype('"')]
    call setreg(regname, value, type)
endfunction "}}}

function! s:buf_edit() "{{{
    let regname = s:get_regname_on_cursor()
    if regname ==# s:INVALID_REGISTER
        return
    endif
    call s:open_register_buffer(regname)
endfunction "}}}
function! s:open_register_buffer(regname) "{{{
    let open_command =
    \   exists('g:regbuf_edit_open_command') ?
    \       g:regbuf_edit_open_command :
    \       g:regbuf_open_command
    call s:create_buffer('regbuf:edit:@' . a:regname, open_command, 'acwrite')

    call s:write_register_value(a:regname)

    command!
    \   -bar -buffer -nargs=*
    \   RegbufEditApply
    \   call s:buf_edit_apply(<f-args>)
    command!
    \   -bar -buffer
    \   RegbufEditCancel
    \   close

    if !g:regbuf_no_default_edit_autocmd
        augroup regbuf-edit
            autocmd!
            autocmd BufWritecmd <buffer> RegbufEditApply
        augroup END
    endif

    nnoremap <buffer> <Plug>(regbuf-edit-cancel) :<C-u>RegbufEditCancel<CR>
    nnoremap <buffer> <Plug>(regbuf-edit-apply)  :<C-u>RegbufEditApply<CR>

    setfiletype regbuf-edit
endfunction "}}}
function! s:write_register_value(regname) "{{{
    let [value, b:regbuf_edit_regtype] = [getreg(a:regname, 1), getregtype(a:regname)]
    let b:regbuf_edit_regname = a:regname
    let b:regbuf_edit_regtype = getregtype(a:regname)
    call setline(1, split(value, '\n'))
endfunction "}}}

function! s:buf_edit_apply() "{{{
    if !exists('b:regbuf_edit_regname')
        echoerr "b:regbuf_edit_regname is deleted by someone. Can't continue applying..."
        return
    endif

    let INVALID_REGTYPE = -1
    let [value, type] = [
    \   join(getline(1, '$'), "\n"),
    \   exists('b:regbuf_edit_regtype') ? b:regbuf_edit_regtype : INVALID_REGTYPE
    \]

    call call('setreg', [b:regbuf_edit_regname, value] + (type !=# INVALID_REGTYPE ? [type] : []))

    setlocal nomodified
endfunction "}}}


function! s:create_buffer(name, open_command, buftype) "{{{
    let winnr = bufwinnr(bufnr(a:name))
    if winnr ==# -1
        execute a:open_command a:name
        setlocal bufhidden=hide noswapfile nobuflisted
        let &l:buftype = a:buftype
    else
        execute winnr 'wincmd w'
    endif
endfunction "}}}


function! s:get_regname_on_cursor() "{{{
    if expand('%') !=# 'regbuf:registers'
        return s:INVALID_REGISTER
    endif
    let line = getline('.')
    if line[0] !=# '"'
        return s:INVALID_REGISTER
    endif
    return line[1]
endfunction "}}}


" TODO
function! s:preview_register() "{{{
    let regname = s:get_regname_on_cursor()
    if regname ==# s:INVALID_REGISTER
        return
    endif

    " TODO
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
