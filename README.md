11月9号从git中更新后编译的64位GVIM，支持Python3.2、Python2.7、Perl、TCL/TC应该算是挺全的了，补丁的到353。

修改了一行源码，用于解决GVIM白边的问题，因为我使用的配色为molokai，所以给的颜色是黑色的。

修改 gui_w32.c  第 1471 行.
    wndclassw.hbrBackground = CreateSolidBrush(RGB(27, 29, 30));

编码时bigvim.bat中的内容
    nmake -f Make_mvc.mak GUI=yes OLE=yes PERL=C:\Perl64 DYNAMIC_PERL=yes PERL_VER=514 PYTHON=C:\Python27 DYNAMIC_PYTHON=yes PYTHON_VER=27 PYTHON3=C:\Python32 DYNAMIC_PYTHON3=yes PYTHON3_VER=32  TCL=c:\tcl TCL_VER=85 DYNAMIC_TCL=yes %1 IME=yes CSCOPE=yes

vim73目录还放置了几个dll文件

  - gvimext.dll是修改过后的，功能简化了，当选择单个文件时右键菜单只会出现一个 "Edit with VIM"，当选择多个文件同时会多出个"Diff with VIM"，同时加入了图标。
  - gvimfullscreen.dll是个相当全的东西，能让VIM全屏、透明、总在最前功能，在vimrc中设置如下则可使用

	" {{{ Win平台下窗口全屏组件 gvimfullscreen.dll
	" Alt + Enter 全屏切换
	" Shift + t 降低窗口透明度
	" Shift + y 加大窗口透明度
	" Shift + r 切换Vim是否总在最前面显示
	if has('gui_running') && has('gui_win32') && has('libcall')
		let g:MyVimLib = 'gvimfullscreen.dll'
		function! ToggleFullScreen()
			"let s:IsFullScreen = libcallnr("gvimfullscreen.dll", 'ToggleFullScreen', 0)
			"let s:IsFullScreen = libcallnr("gvimfullscreen.dll", 'ToggleFullScreen', 27 + 29*256 + 30*256*256)
			call libcall(g:MyVimLib, 'ToggleFullScreen', 27 + 29*256 + 30*256*256)
		endfunction
		"映射 Alt+Enter 切换全屏vim
		map <a-enter> <esc>:call ToggleFullScreen()<cr>
		"Vim启动的时候自动调用InitVim 以去除Vim的白色边框
		autocmd GUIEnter * call libcallnr(g:MyVimLib, 'InitVim', 0)
	
		let g:VimAlpha = 240
		function! SetAlpha(alpha)
			let g:VimAlpha = g:VimAlpha + a:alpha
			if g:VimAlpha < 180
				let g:VimAlpha = 180
			endif
			if g:VimAlpha > 255
				let g:VimAlpha = 255
			endif
			call libcall(g:MyVimLib, 'SetAlpha', g:VimAlpha)
		endfunction
		"增加Vim窗体的不透明度
		nmap <s-t> <esc>:call SetAlpha(10)<cr>
		"增加Vim窗体的透明度
		nmap <s-y> <esc>:call SetAlpha(-10)<cr>
	
		let g:VimTopMost = 0
		function! SwitchVimTopMostMode()
			if g:VimTopMost == 0
				let g:VimTopMost = 1
			else
				let g:VimTopMost = 0
			endif
			call libcall(g:MyVimLib, 'EnableTopMost', g:VimTopMost)
		endfunction
		"切换Vim是否在最前面显示
		nmap <s-r> <esc>:call SwitchVimTopMostMode()<cr>
	endif
	" }}}
