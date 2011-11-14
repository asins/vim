" vim:foldmethod=marker:fen:
scriptencoding utf-8

" DOCUMENT {{{
"==================================================
" Name: WinMove
" Version: 0.0.4
" Author:  tyru <tyru.exe@gmail.com>
" Last Change: 2010-12-27.
" License: Distributable under the same terms as Vim itself (see :help license)
"
" Change Log: {{{
"   0.0.0: Initial upload.
"   0.0.1: my e-mail address was wrong :-p
"   0.0.2: Allow range before mappings
"          e.g.: '10<Up>' moves gVim window to the upper 10 times
"   0.0.3: Fix bug: gvim moves oppositely on MacVim.
"          Thanks ujihisa for the patch.
"   0.0.4: Fix bug: :winpos raised an error
"          because :winpos is not available at startup.
"          (the problem occurred on gVim Windows XP)
" }}}
"
" Description:
"   Move your Vim from mappings.
"
" Usage:
"   MAPPING:
"       <Up>        move your Vim up.
"       <Right>     move your Vim right.
"       <Down>      move your Vim down.
"       <Left>      move your Vim left.
"
"   GLOBAL VARIABLES:
"       g:wm_move_up (default:'<Up>')
"           if empty string, no mapping is defined.
"
"       g:wm_move_right (default:'<Right>')
"           if empty string, no mapping is defined.
"
"       g:wm_move_down (default:'<Down>')
"           if empty string, no mapping is defined.
"
"       g:wm_move_left (default:'<Left>')
"           if empty string, no mapping is defined.
"
"       g:wm_move_x (default:20)
"           Vim use this when move left or right.
"
"       g:wm_move_y (default:15)
"           Vim use this when move up or down.
"
"
"==================================================
" }}}

" CHECK AVAILABILITY {{{

" NOTE: Delay the a load of this script until VimEnter.
" Because :winpos raised an error on gVim (Windows)
" while loading this script at startup.
augroup winmove
    autocmd!
    autocmd VimEnter * let s:delayed = 1 | source <sfile>
augroup END
if !exists('s:delayed')
    finish
endif

" THIS PLUGIN WORK ON TERMINAL ALSO.
try
    silent winpos
catch /^Vim\%((\a\+)\)\=:E188/
    finish
endtry
" }}}

" INCLUDE GUARD {{{
if exists('g:loaded_winmove') && g:loaded_winmove != 0
    finish
endif
let g:loaded_winmove = 1
" }}}

" SAVING CPO {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" GLOBAL VARIABLES {{{
if ! exists('g:wm_move_up')
    let g:wm_move_up = '<Up>'
endif
if ! exists('g:wm_move_right')
    let g:wm_move_right = '<Right>'
endif
if ! exists('g:wm_move_down')
    let g:wm_move_down = '<Down>'
endif
if ! exists('g:wm_move_left')
    let g:wm_move_left = '<Left>'
endif
if ! exists('g:wm_move_x')
    let g:wm_move_x = 20
endif
if ! exists('g:wm_move_y')
    let g:wm_move_y = 15
endif
" }}}

" FUNCTION DEFINITION {{{

function! s:MoveTo(dest)
    if has('gui_running')
        let winpos = { 'x':getwinposx(), 'y':getwinposy() }
    else
        redir => out | silent! winpos | redir END
        let mpos = matchlist(out, '^[^:]\+: X \(-\?\d\+\), Y \(-\?\d\+\)')
        if len(mpos) == 0 | return | endif
        let winpos = { 'x':mpos[1], 'y':mpos[2] }
    endif
    let repeat = v:count1

    if a:dest == '>'
        let winpos['x'] = winpos['x'] + g:wm_move_x * repeat
    elseif a:dest == '<'
        let winpos['x'] = winpos['x'] - g:wm_move_x * repeat
    elseif a:dest == '^'
        let winpos['y'] = has("gui_macvim") ?
              \ winpos['y'] + g:wm_move_y * repeat :
              \ winpos['y'] - g:wm_move_y * repeat
    elseif a:dest == 'v'
        let winpos['y'] = has("gui_macvim") ?
              \ winpos['y'] - g:wm_move_y * repeat :
              \ winpos['y'] + g:wm_move_y * repeat
    endif
    if winpos['x'] < 0 | let winpos['x'] = 0 | endif
    if winpos['y'] < 0 | let winpos['y'] = 0 | endif

    execute 'winpos' winpos['x'] winpos['y']
endfunction

" }}}

" MAPPING {{{
nnoremap <silent> <Plug>(winmove-up)     :<C-u>call <SID>MoveTo('^')<CR>
nnoremap <silent> <Plug>(winmove-right)  :<C-u>call <SID>MoveTo('>')<CR>
nnoremap <silent> <Plug>(winmove-down)   :<C-u>call <SID>MoveTo('v')<CR>
nnoremap <silent> <Plug>(winmove-left)   :<C-u>call <SID>MoveTo('<')<CR>

if g:wm_move_up != ''
    execute 'nmap' g:wm_move_up '<Plug>(winmove-up)'
endif
if g:wm_move_right != ''
    execute 'nmap' g:wm_move_right '<Plug>(winmove-right)'
endif
if g:wm_move_down != ''
    execute 'nmap' g:wm_move_down '<Plug>(winmove-down)'
endif
if g:wm_move_left != ''
    execute 'nmap' g:wm_move_left '<Plug>(winmove-left)'
endif
" }}}

" RESTORE CPO {{{
let &cpo = s:save_cpo
" }}}

