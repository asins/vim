" File: template.vim
" Desption: autoload content from template file.
" Author: 闲耘™(hotoo.cn[AT]gmail.com)
" Last Change: 2010/11/25

if exists('loaded_smart_template')
    finish
endif
let loaded_smart_template=1

if !exists('g:template_autoload')
    let g:template_autoload = 1
endif
if !exists('g:template_author')
    let g:template_author = ''
endif

function! s:replace(text, repl, flag)
    let pos=[1, 1]
    call cursor(1, 1)
    let hasfind=searchpos('\C'.a:text)
    while hasfind!=[0,0]
        let pos = hasfind
        let line = substitute(getline('.'), a:text, a:repl, a:flag)
        call setline('.', line)

        let hasfind = 'g'==a:flag?searchpos('\C'.a:text,'W'):[0,0]
    endwhile

    return pos
endfunction

fun! s:filename(default)
	let filename = expand('%:t:r')
    return ''==filename ? a:default : filename
endf
fun! s:Filename(default)
    return substitute(s:filename(a:default), '\<.', '\U\0', 'g')
endf
fun! s:FILENAME(default)
    return substitute(s:filename(a:default), '.*', '\U\0', '')
endf

function! s:template()
    call s:replace('${datetime}', strftime("%Y-%m-%d %H:%M:%S"), 'g')
    call s:replace('${date}', strftime("%Y-%m-%d"), 'g')
    call s:replace('${FILENAME}', s:FILENAME('UNAMED'), 'g')
    call s:replace('${FileName}', s:Filename('Unamed'), 'g')
    call s:replace('${filename}', s:filename('unamed'), 'g')
    call s:replace('${author}', g:template_author, 'g')
    let cur = s:replace('${cursor}', '', '')
    call setpos(".", [0, cur[0], cur[1]])
    "call cursor(cur)

    return ''
endfunction

" {FileType:FileExt}
let s:FileType = {
    \ "javascript" : "js",
    \ "actionscript": "as",
    \ "aspvbs" : "asp"
\ }

function! s:getExt()
    let ext = expand("%:e")
    if ""==ext
        let ext = has_key(s:FileType, &ft) ? s:FileType[&ft] : &ft
    endif
    return ext
endfunction

function! LoadTemplate()
    let ext=s:getExt()
    if ""==ext
        return 'template'
    endif

    if !exists('g:template_dir')
        let paths = split(globpath(&rtp, 'template/template.'.ext), "\n")
        if(0 == len(paths))
            return 'template'
        endif
        let path = paths[0]
    else
        let path = g:template_dir . 'template.'.ext
    endif
    try
        exec '0r '.path
        call s:template()
    catch /.*/
        return 'template'
    endtry

    return ''
endfunction

if 0 != g:template_autoload
    autocmd! BufNewFile * silent! :call LoadTemplate()
endif
command! -nargs=0 Template call LoadTemplate()
