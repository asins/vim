" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" Syntax Stuff {{{
if has('syntax') && exists('g:syntax_on') && !has('syntax_items') &&
	    \ (!exists('g:proj_flags') || match(g:proj_flags, '\Cs')!=-1)
    syntax match projectDescriptionDir '^\s*.\{-}=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
    syntax match projectDescription    '\<.\{-}='he=e-1,me=e-1         contained nextgroup=projectDirectory contains=projectWhiteError
    syntax match projectDescription    '{\|}'
    syntax match projectDirectory      '=\(\\ \|\f\|:\)\+'             contained
    syntax match projectDirectory      '=".\{-}"'                      contained
    syntax match projectScriptinout    '\<in\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
    syntax match projectScriptinout    '\<out\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
    syntax match projectComment        '#.*'
    syntax match projectCD             '\<CD\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
    syntax match projectFilterEntry    '\<filter\s*=.*"'               contains=projectWhiteError,projectFilterError,projectFilter,projectFilterRegexp
    syntax match projectFilter         '\<filter='he=e-1,me=e-1        contained nextgroup=projectFilterRegexp,projectFilterError,projectWhiteError
    syntax match projectFlagsEntry     '\<flags\s*=\( \|[^ ]*\)'       contains=projectFlags,projectWhiteError
    syntax match projectFlags          '\<flags'                       contained nextgroup=projectFlagsValues,projectWhiteError
    syntax match projectFlagsValues    '=[^ ]* 'hs=s+1,me=e-1          contained contains=projectFlagsError
    syntax match projectFlagsError     '[^rtTsSwl= ]\+'                contained
    syntax match projectWhiteError     '=\s\+'hs=s+1                   contained
    syntax match projectWhiteError     '\s\+='he=e-1                   contained
    syntax match projectFilterError    '=[^"]'hs=s+1                   contained
    syntax match projectFilterRegexp   '=".*"'hs=s+1                   contained
    syntax match projectFoldText       '^[^=]\+{'

    highlight def link projectDescription  Identifier
    highlight def link projectScriptinout  Identifier
    highlight def link projectFoldText     Identifier
    highlight def link projectComment      Comment
    highlight def link projectFilter       Identifier
    highlight def link projectFlags        Identifier
    highlight def link projectDirectory    Constant
    highlight def link projectFilterRegexp String
    highlight def link projectFlagsValues  String
    highlight def link projectWhiteError   Error
    highlight def link projectFlagsError   Error
    highlight def link projectFilterError  Error
endif "}}}

setlocal cursorline
let maplocalleader = ';'
let b:current_syntax = "vimprj"
command! -nargs=0 -buffer Load  		Project %
" vim: ts=8 noet
