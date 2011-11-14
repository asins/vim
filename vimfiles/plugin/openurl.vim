" Copyright (c) 2010 Kenko Abe
"
"
" Summary
" =======
" The OprnUrl function opens a url which is a first one in the line
"
" Require
" =======
" You need a python interface.
"
" Usage
" =====
" If there is a line such that
"
" Sample line. http://aaa http://bbb
"
" You use ':OpenUrl' command in this line, 
" then you can open http://aaa in a default web browser.
"
"
"
" I set a command for OpenUrl function, such that
"
" command OpenUrl :call OpenUrl()
" 
" You can change command name by changing above command name 'OpenUrl'.
"
" example)
" command AnotherOpenUrlName :call OpenUrl()
"



" define OpenUrl function
function! OpenUrl()
python << EOM
# coding=utf-8

import vim
import re
import webbrowser

re_obj = re.compile(r'https?://[a-zA-Z0-9-./"#$%&\':?=_]+')
line = vim.current.line
match_obj = re_obj.search(line)

try:
    url = match_obj.group()
    webbrowser.open(url)
    print 'open URL : %s' % url
except:
    print 'fialed! : open URL'

EOM
endfunction


" set a command for OpenUrl function
command OpenUrl :call OpenUrl()
