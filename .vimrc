" Author: Asins - asinsimple AT gmail DOT com
"         Get latest vimrc from http://nootn.com/
" Last Modified: 2016-03-09 14:06 (+0800)

" 准备工作 {{{1
" 判定语句及定义变量
"   判定当前操作系统类型 {{{2
if has("win32") || has("win95") || has("win64") || has("win16")
	let s:isWindows=1
	let $VIMFILES = $VIM."/vimfiles"
else
	let s:isWindows=0
	let $VIMFILES = $HOME."/.vim"
endif
if (!s:isWindows
			\ && (has('mac') || has('macunix') || has('gui_macvim') ||
			\ (!executable('xdg-open') && system('uname') =~? '^darwin')))
	let s:isMac=1
else
	let s:isMac=0
endif
"   }}}
"   判定当前是否图形界面 {{{2
if has("gui_running")
	let s:isGUI=1
else
	let s:isGUI=0
endif
"   }}}
"   判定当前终端是否256色 {{{2
if (s:isWindows==0 && s:isGUI==0 &&
			\ (&term =~ "256color" || &term =~ "xterm" || &term =~ "fbterm"))
	let s:isColor=1
else
	let s:isColor=0
endif
"   }}}
"   判定当前是否有 CTags {{{2
if executable('ctags')
	let s:hasCTags=1
else
	let s:hasCTags=0
endif
"   }}}
"   判定当前是否有 Ag {{{2
if executable('ag')
	let s:hasAg=1
else
	let s:hasAg=0
endif
"   }}}
" 设置自动命令组
"   特定文件类型自动命令组 {{{2
augroup Filetype_Specific
	autocmd!
augroup END
"   }}}
"   默认自动命令组 {{{2
augroup MyAutoCmd
	autocmd!
augroup END
"   }}}
"   设置 <Leader>字符 {{{2
let mapleader=","
let maplocalleader=","
"   }}}
" 设置缓存目录 {{{2
" (以下取自 https://github.com/bling/dotvim )
let s:cache_dir = $VIMFILES."/.cache"
"   }}}
" }}}

"  定义函数 {{{1
" (以下取自 https://github.com/bling/dotvim )
"    获取缓存目录 {{{2
function! s:get_cache_dir(suffix)
	return resolve(expand(s:cache_dir . "/" . a:suffix))
endfunction
"   }}}
"   保证该目录存在，若不存在则新建目录 {{{2
function! EnsureExists(path)
	if !isdirectory(expand(a:path))
		call mkdir(expand(a:path))
	endif
endfunction
"   }}}
" (以下取自 https://github.com/lilydjwg/dotvim )
"   取得光标处的匹配 {{{2
function! GetPatternAtCursor(pat)
	let col = col('.') - 1
	let line = getline('.')
	let ebeg = -1
	let cont = match(line, a:pat, 0)
	while (ebeg >= 0 || (0 <= cont) && (cont <= col))
		let contn = matchend(line, a:pat, cont)
		if (cont <= col) && (col < contn)
			let ebeg = match(line, a:pat, cont)
			let elen = contn - ebeg
			break
		else
			let cont = match(line, a:pat, contn)
		endif
	endwhile
	if ebeg >= 0
		return strpart(line, ebeg, elen)
	else
		return ""
	endif
endfunction
"   }}}
"   用浏览器打开链接 {{{2
function! OpenURL()
	let s:url = GetPatternAtCursor('\v%(https?|ftp)://[^]''" \t\r\n>*。，\`)]*')
	if s:url == ""
		echohl WarningMsg
		echomsg '在光标处未发现URL！'
		echohl None
	else
		echo '打开URL：' . s:url
		if s:isWindows
			" start 不是程序，所以无效。并且，cmd 只能使用双引号
			" call system("cmd /q /c start \"" . s:url . "\"")
			" call system("D:\\Programs\\Google Chrome\\bin\\chrome.exe \"" . s:url . "\"")
		elseif s:isMac
			call system("open -a \"/Applications/Google Chrome.app\" '" . s:url . "'")
		else
			call system("setsid firefox '" . s:url . "' &")
		endif
	endif
	unlet s:url
endfunction
"   }}}
" (以下取自 https://github.com/Shougo/shougo-s-github )
"   切换选项开关 {{{2
function! ToggleOption(option_name)
	execute 'setlocal' a:option_name.'!'
	execute 'setlocal' a:option_name.'?'
endfunction
"   }}}
" (以下取自 https://github.com/terryma/dotfiles )
"   调整 Quickfix 窗口高度 {{{2
function! AdjustWindowHeight(minheight, maxheight)
	execute max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction
"   }}}
" (以下为自己原创修改或不记得出处的 )
"   删除文件末尾空格 {{{2
function! StripTrailingWhitespace()
	" Preparation: save last search, and cursor position.
	let _s=@/
	let l = line(".")
	let c = col(".")
	" do the business:
	%s/
$\|\s\+$//e
	" clean up: restore previous search history, and cursor position
	let @/=_s
	call cursor(l, c)
endfunction
"   }}}
"   回车时前字符为{时自动换行补全 {{{2
function! <SID>OpenSpecial(ochar, cchar)
	let line = getline('.')
	let col = col('.') - 2
	if(line[col] != a:ochar)
		if(col > 0)
			return "\<Esc>a\<CR>"
		else
			return "\<CR>"
		endif
	endif
	if(line[col+1] != a:cchar)
		call setline('.',line[:(col)].a:cchar.line[(col+1):])
	else
		call setline('.',line[:(col)].line[(col+1):])
	endif
	return "\<Esc>a\<CR>;\<CR>".a:cchar."\<Esc>\"_xk$\"_xa"
endfunction
"   }}}
"   更新最后修改时间 {{{2
function! <SID>UpdateLastMod()
	" preparation: save last search, and cursor position.
	let _s=@/
	let l = line(".")
	let c = col(".")

	let n = min([10, line('$')]) " 检查头部多少行
	let timestamp = strftime('%Y-%m-%d %H:%M (%z)') " 时间格式
	let timestamp = substitute(timestamp, '%', '\%', 'g')
	let pat = substitute('Last Modified:\s*\zs.*\ze', '%', '\%', 'g')
	keepjumps silent execute '1,'.n.'s%^.*'.pat.'.*$%'.timestamp.'%e'

	" clean up: restore previous search history, and cursor position
	let @/=_s
	call cursor(l, c)
endfunction
"   }}}
" }}}

" Plug.vim 插件管理器 {{{1
"   加载Plug及插件 开始 未则自行下载 {{{2
"     Plug参数说明 {{{3
       " | Option                  | Description                          |
       " | ----------------------- | ------------------------------------ |
       " | `branch`/`tag`/`commit` | 存储库使用的 branch/tag/commit       |
       " | `rtp`                   | 子目录包含的Vim插件                  |
       " | `dir`                   | 自定义该插件目录                     |
       " | `as`                    | 插件重命令                           |
       " | `do`                    | 更新后的挂钩（字符串或函数引用）     |
       " | `on`                    | 按需加载：命令或 `<Plug>`-mappings   |
       " | `for`                   | 按需加载：文件类型                   |
       " | `frozen`                | 除非显式指定，否则不更新             |
"     }}}
if empty(glob("~/.vim/autoload/plug.vim"))
	" Ensure all needed directories exist  (Thanks @kapadiamush)
	execute 'mkdir -p ~/.vim/plugged'
	execute 'mkdir -p ~/.vim/autoload'
	" Download the actual plugin manager
	execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif
call plug#begin('~/.vim/plugged')
"   }}}
"   核心插件 {{{2
" 全局文内搜索
if s:hasAg
	Plug 'rking/ag.vim'
" :Ag [options] pattern [directory]
" :Ag FooBar foo/**/*.py 等同于 :Ag -G foo/.*/[^/]*\.py$ FooBar
endif
" vim-airline 是更轻巧的 vim-powerline 代替品
Plug 'bling/vim-airline'
" MatchIt 对%命令进行扩展使得能在嵌套标签和语句之间跳转 % g% [% ]% 使用说明 {{{3
" 映射     描述
" %        正向匹配
" g%       反向匹配
" [%       定位块首
" ]%       定位块尾
" }}}
Plug 'matchit.zip', { 'for': ['html', 'xml'] }
" Repeat -- 支持普通模式使用"."来重复执行一些插件的命令
Plug 'tpope/vim-repeat'
if s:hasCTags
	" 提供单个源代码文件的函数列表之类的功能，强于 Taglist
	Plug 'majutsushi/tagbar'
endif
" 树形的文件系统浏览器（替代 Netrw)，功能比 Vim 自带的 Netrw 强大
Plug 'scrooloose/nerdtree'
" NERDTree的Git显示支持
Plug 'Xuyuanp/nerdtree-git-plugin'
" 模糊文件查找
Plug 'ctrlpvim/ctrlp.vim'
" ctrlp的文件内函数查找
Plug 'tacahiroy/ctrlp-funky'
" 在 Visual 模式下使用 */# 跳转
Plug 'thinca/vim-visualstar'
" }}}
"   系统支持 {{{2
" 文件重命令 使用说明 {{{3
" :Renamer 将当前文件所在文件夹下的内容显示在一个新窗口
" :Ren 开始重命名
" }}}
Plug 'asins/renamer.vim'
" 自动创建目录
Plug 'auto_mkdir'
" 以root权限打开文件 使用说明 {{{3
  " :SudoRead[!] [file]
  " :[range]SudoWrite[!] [file]
" }}}
if !s:isWindows
	Plug 'chrisbra/SudoEdit.vim'
endif
" 在终端下自动开启关闭 paste 选项
Plug 'ConradIrwin/vim-bracketed-paste'
"   }}}
"   文本编辑 {{{2
" 快速打开子文件
Plug 'asins/OpenRequireFile.vim'
" HTML代码快速生成 使用说明 {{{3
" 常用命令可看：http://nootn.com/blog/Tool/23/
" <c-y>m  合并多行
" }}}
Plug 'mattn/emmet-vim', { 'for': [ 'css', 'html', 'less', 'sass', 'scss', 'xml', 'xsd', 'xsl', 'xslt', 'mustache' ] }
" 高亮显示光标处配对的HTML标签
Plug 'MatchTag', { 'for': [ 'html', 'xml' ] }
" 比较指定文本块 使用说明 {{{3
" :Linediff 设置对比块，两次后会开启vimDiff模式
" :LinediffReset 清除Diff标记
" }}}
Plug 'AndrewRadev/linediff.vim' , { 'on': [ 'Linediff', 'LinediffReset' ] }
" 专注编辑选定区域 使用说明 {{{3
" <Leader>nr       - 将当前选中内容在一个缩小的窗口中打开
" }}}
Plug 'chrisbra/NrrwRgn'
" 给各种 tags 标记不同的颜色，便于观看调试的插件 使用说明 {{{3 test
" (以下取自 http://easwy.com/blog/archives/advanced-vim-skills-syntax-on-colorscheme/ )
" 当我输入“,hl”时，就会把光标下的单词高亮，在此单词上按“,hh”会清除该单词的高亮。
" 如果在高亮单词外输入“,hh”，会清除所有的高亮。
" 你也可以使用virsual模式选中一段文本，然后按“,hl”，会高亮你所选中的文本；或者
" 你可以用“,hr”来输入一个正则表达式，这会高亮所有符合这个正则表达式的文本。
"
" 你可以在高亮文本上使用“,#”或“,*”来上下搜索高亮文本。在使用了“,#”或“,*”后，就
" 可以直接输入“#”或“*”来继续查找该高亮文本，直到你又用“#”或“*”查找了其它文本。
" <Leader>* 当前MarkWord的下一个     <Leader># 当前MarkWord的上一个
" <Leader>/ 所有MarkWords的下一个    <Leader>? 所有MarkWords的上一个
"
" 如果你在启动vim后重新执行了colorscheme命令，或者载入了会话文件，那么mark插件
" 的颜色就会被清掉，解决的办法是重新source一下mark插件。或者像我一样，把mark插
" 件定义的highlight组加入到你自己的colorscheme文件中。
" }}}
Plug 'dimasg/vim-mark'
" 文本对齐 tabular 比 Align 更简单
Plug 'godlygeek/tabular' , { 'on': [ 'Tabularize', 'AddTabularPipeline' ] }
" 中文排版自动规范化
Plug 'hotoo/pangu.vim', { 'on': [ 'Pangu', 'PanguEnable', 'PanguDisable' ], 'for': [ 'markdown', 'text' ] }
" Node功能
Plug 'moll/vim-node', { 'for': [ 'javascript' ] }

" 移动命令增强 使用说明 {{{3
" s 进入搜索状态(最多输入2个字符) 搜索ea
"     ; 向下搜索  , 向上搜索
"     <Ctrl+o> 跳到搜索起始位置
" }}}
Plug 'justinmk/vim-sneak'
" 连续按 j/k 时加速移动光标
Plug 'rhysd/accelerated-jk'
" 光标选择功能
Plug 'terryma/vim-multiple-cursors'
" 代码注释 使用说明 {{{3
" <Leader>ca 在可选的注释方式之间切换，比如C/C++ 的块注释/* */和行注释//
" <Leader>cc 注释当前行
" <Leader>cs 以”性感”的方式注释
" <Leader>cA 在当前行尾添加注释符，并进入Insert模式
" <Leader>cu 取消注释
" <Leader>cm 添加块注释
" }}}
Plug 'scrooloose/nerdcommenter'
" 据说tcomment_vim 比 nerdcommenter 更智能
" Surround -- 快速添加、替换、清除包围符号、标签
" Plug 'tpope/vim-surround'
" Plug 'tomtom/tcomment_vim'
" 显示尾部多余空格
" Plug 'ShowTrailingWhitespace'
" VisIncr -- 给vim增加生成递增或者递减数列的功能，支持十进制 十六进制 日期 星期等功能强大灵活
" Plug 'VisIncr'
"   }}}
"   格式化 & 美化 {{{2
" 打散合并单行语句  使用说明 {{{3
" gS 分隔一个单行代码为多行
" gJ (光标在区块的第一行) 将区块合并为单行
" }}}
Plug 'AndrewRadev/splitjoin.vim' , { 'on': [ 'SplitjoinJoin', 'SplitjoinSplit' ] }
" html/css/js 代码格式化 需要NodeJs的支持
if executable('node') || executable('nodejs')
	Plug 'maksimr/vim-jsbeautify',  { 'for': [ 'css', 'html', 'javascript', 'json', 'less', 'mustache' ] }
endif
"   }}}
"   缩进 & 着色 {{{2
" 通用的缩进优化
Plug 'IndentAnything'
" vim-indent-guides -- 显示缩进线
Plug 'nathanaelkane/vim-indent-guides'
" 大大加强JS的语法及缩进支持
Plug 'pangloss/vim-javascript', { 'for': [ 'javascript' ] }
" Plug 'jiangmiao/simple-javascript-indenter', { 'for': [ 'javascript' ] }
" CSS类语法
Plug 'ap/vim-css-color', { 'for': [ 'css', 'scss', 'sass', 'less' ] }
Plug 'othree/html5.vim', { 'for': ['html'] }
Plug 'othree/html5-syntax.vim', { 'for': ['html'] }
Plug 'othree/xml.vim', { 'for': ['html', 'xml'] }
" HTML/XML闭合标签间通过 # % 跳转
Plug 'tpope/vim-ragtag', { 'for': ['html', 'xml'] }
" Nginx语法
Plug 'evanmiller/nginx-vim-syntax', { 'for': [ 'nginx' ] }
" Markdown 语法
Plug 'tpope/vim-markdown', { 'for': [ 'markdown' ] }
"   }}}
"   代码检查 & 代码提示 & 文档查询 {{{2
" 自动完成 需要lua支持
Plug 'Shougo/neocomplete.vim'
" JavaScript的语义分析提示 需到目录中执行npm install 使用阿里中国仓库加快安装速度
Plug 'marijnh/tern_for_vim', { 'for': 'javascript', 'do': 'npm install --registry=https://registry.npm.taobao.org'}
" 包含很多语言的语法与编码风格检查插件
Plug 'scrooloose/syntastic', { 'for': ['php', 'javascript', 'css', 'less', 'scss'] }
" Vim 中文文档计划
Plug 'asins/vimcdoc'
" Vim的关键词字典
Plug 'asins/vim-dict'
" 直接启用Dash查询相关手册 Mac独有软件 使用说明 {{{3
" :Dash printf  在所有手册中查找printf
" :Dash! [word] 在所有手册中查找光标所在或指定的
" :Dash setTimeout javascript  在JavaScript手册中查找setTimeout
" }}}
if s:isMac
	Plug 'rizzatti/dash.vim'
endif
"   }}}
"   主题及配色 {{{2
Plug 'crusoexia/vim-monokai'
"   }}}
"   加载Plug及插件 结束{{{2
call plug#end()
filetype plugin indent on
"   }}}
" }}}

" 自定义设置 {{{1
set nocompatible " be iMproved
" 以下设置在 Vim 全屏运行时 source vimrc 的时候不能再执行否则会退出全屏
if !exists('g:VimrcIsLoad')
"   设置语言编码 {{{2
	" 解决console输出乱码
	language messages zh_CN.UTF-8
	" set langmenu=zh_CN.UTF-8
	" 显示中文帮助
	set helplang=cn
	if s:isWindows && has("multi_byte")
		set termencoding=cp850
	else
		set termencoding=utf-8
	endif
	set fileencodings=utf-8,chinese,taiwan,ucs-2,ucs-2le,ucs-bom,latin1,gbk,gb18030,big5,utf-16le,cp1252,iso-8859-15
	set encoding=utf-8
	set fileencoding=utf-8
"  }}}
"  设置图形界面选项  {{{2
	if s:isGUI
		set shortmess=atI  " 启动的时候不显示那个援助乌干达儿童的提示
		" 禁止显示滚动条
		set guioptions-=r
		set guioptions-=R
		set guioptions-=L
		set guioptions-=L
		" 禁止显示菜单和工具条
		set guioptions-=T "工具栏
		set guioptions-=m "菜单
		if s:isWindows
			autocmd MyAutoCmd GUIEnter * simalt ~x    " 在Windows下启动时最大化窗口
			if has('directx')
				set renderoptions=type:directx
			endif
		endif
		set guitablabel=%N\ \ %t\ %M   "标签页上显示序号
	endif
"   }}}
"   图形与终端 {{{2
" 以下设置在 Vim 全屏运行时 source vimrc 的时候不能再执行否则会退出全屏
	" 字符之间插入的像素行数
	set linespace=0
	" 设置显示字体和大小
	set guifont=Monaco:h14
	" 设置配色方案 {{{3
	let colorscheme = 'monokai'
	" (以下取自 https://github.com/lilydjwg/dotvim )
	if s:isGUI
		" 有些终端不能改变大小
		set columns=88
		set lines=32
		set cursorline
		" 原为double，为了更好地显示airline，改为single
		set ambiwidth=single
		exe 'colorscheme' colorscheme
	elseif has("unix")
		" 原为double，为了更好地显示airline，改为single
		set ambiwidth=single
		" 防止退出时终端乱码
		" 这里两者都需要。只前者标题会重复，只后者会乱码
		set t_fs=(B
		set t_IE=(B
		if s:isColor
			set cursorline  "Current Line Adornment
			exe 'colorscheme' colorscheme
			set t_Co=256
		else
			" 在Linux文本终端下非插入模式显示块状光标
			if &term == "linux" || &term == "fbterm"
				set t_ve+=[?6c
				augroup MyAutoCmd
					autocmd InsertEnter * set t_ve-=[?6c
					autocmd InsertLeave * set t_ve+=[?6c
					" autocmd VimLeave * set t_ve-=[?6c
				augroup END
			endif
			if &term == "fbterm"
				set cursorline
				exe 'colorscheme' colorscheme
			elseif $TERMCAP =~ 'Co#256'
				set t_Co=256
				set cursorline
				exe 'colorscheme' colorscheme
			else
				" 暂时只有这个配色比较适合了
				colorscheme default
			endif
		endif
		" 在不同模式下使用不同颜色的光标
		" 不要在 ssh 下使用
		if s:isColor && !exists('$SSH_TTY')
			let color_normal = 'HotPink'
			let color_insert = 'RoyalBlue1'
			let color_exit = 'green'
			if &term =~ 'xterm\|rxvt'
				exe 'silent !echo -ne "\e]12;"' . shellescape(color_normal, 1) . '"\007"'
				let &t_SI="\e]12;" . color_insert . "\007"
				let &t_EI="\e]12;" . color_normal . "\007"
				exe 'autocmd VimLeave * :silent !echo -ne "\e]12;"' . shellescape(color_exit, 1) . '"\007"'
			elseif &term =~ "screen"
				if s:isTmux
					if &ttymouse == 'xterm'
						set ttymouse=xterm2
					endif
					exe 'silent !echo -ne "\033Ptmux;\033\e]12;"' . shellescape(color_normal, 1) . '"\007\033\\"'
					let &t_SI="\033Ptmux;\033\e]12;" . color_insert . "\007\033\\"
					let &t_EI="\033Ptmux;\033\e]12;" . color_normal . "\007\033\\"
					exe 'autocmd VimLeave * :silent !echo -ne "\033Ptmux;\033\e]12;"' . shellescape(color_exit, 1) . '"\007\033\\"'
				elseif !exists('$SUDO_UID') " or it may still be in tmux
					exe 'silent !echo -ne "\033P\e]12;"' . shellescape(color_normal, 1) . '"\007\033\\"'
					let &t_SI="\033P\e]12;" . color_insert . "\007\033\\"
					let &t_EI="\033P\e]12;" . color_normal . "\007\033\\"
					exe 'autocmd VimLeave * :silent !echo -ne "\033P\e]12;"' . shellescape(color_exit, 1) . '"\007\033\\"'
				endif
			endif
			unlet color_normal
			unlet color_insert
			unlet color_exit
		endif
	elseif has('win32') && exists('$CONEMUBUILD')
		" 在 Windows 的 ConEmu 终端下开启256色
		set term=xterm
		set t_Co=256
		let &t_AB="\e[48;5;%dm"
		let &t_AF="\e[38;5;%dm"
		set cursorline
		exe 'colorscheme' colorscheme
	endif
	unlet colorscheme
	" }}}
"   }}}
endif
"   设置更多图形界面选项  {{{2
" 执行宏、寄存器和其它不通过输入的命令时屏幕不会重画(提高性能)
set lazyredraw
" Change the terminal's title
set title
" Avoid command-line redraw on every entered character by turning off Arabic
" shaping (which is implemented poorly).
if has('arabic')
	set noarabicshape
endif
"   }}}
"   Ag 程序参数及输出格式选项 {{{2
if s:hasAg
	set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ --ignore\ '.hg'\ --ignore\ '.svn'\ --ignore\ '.git'\ --ignore\ '.bzr'
	set grepformat=%f:%l:%c:%m
endif
"   }}}
"   关闭错误声音 {{{2
" 去掉输入错误的提示声音
set noerrorbells
" 不要闪烁
set visualbell t_vb=
"    }}}
"   设置文字编辑选项 {{{2
set number   " 显示行号
set smartindent " 智能自动缩进
set cmdheight=1 " 设定命令行的行数为 1
set showmatch " 显示括号配对情况
" set nowrap "不自动换行
syntax on " 自动语法高亮
set wildmenu " Vim自身命令行模式智能补全
set wildmode=full
set background=dark "背景使用黑色，开启molokai终端配色必须指令
set confirm " 在处理未保存或只读文件的时候，弹出确认
set noexpandtab  "键入Tab时不转换成空格
set shiftwidth=4  " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4  " 设置按BackSpace的时候可以一次删除掉4个空格
set tabstop=4 "tab = 4 spaces
" 自动切换当前目录为当前文件所在的目录
set autochdir
set mouse=a " 允许在所有模式下使用鼠标
set nocursorline  " 不突出显示当前行
set nowrapscan " 搜索到文件两端时不重新搜索
set incsearch " 实时搜索
set hlsearch  " 搜索时高亮显示被找到的文本
" 搜索时忽略大小写，但在有一个或以上大写字母时仍大小写敏感
set ignorecase
set smartcase
set nobackup " 覆盖文件时不备份
set nowritebackup "文件保存后取消备份
set noswapfile  "取消交换区
set mousehide  " 键入时隐藏鼠标
set magic " 设置模式的魔术
set sessionoptions=blank,buffers,curdir,folds,slash,tabpages,unix,winsize
set viminfo=%,'1000,<50,s20,h,n$VIMFILES/viminfo
" 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set hidden
set nocursorline  " 不突出显示当前行
" Tab
set smarttab
set backspace=indent,eol,start    " 让退格键和 Delete 键支持删除回车符
" 保证缓存目录存在
call EnsureExists(s:cache_dir)
" 将撤销树保存到文件
if has('persistent_undo')
	set undofile
	let &undodir = s:get_cache_dir("undo")
	" 保证撤销缓存目录存在
	call EnsureExists(&undodir)
endif
" 设置光标之下的最少行数
set scrolloff=3
" 将命令输出重定向到文件的字符串不要包含标准错误
set shellredir=>
" 使用管道
set noshelltemp
set showtabline=0 " Tab栏
set laststatus=2 " 显示状态栏 (默认值为 1, 无法显示状态栏)
" Display extra whitespace
" set list listchars=tab:\|\ ,trail:.,extends:>,precedes:<
" 设置在状态行显示的信息
"set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %c:%l/%L%)
"   }}}
"   设置加密选项 {{{2
" (以下取自 https://github.com/lilydjwg/dotvim )
try
	" Vim 7.4.399+
	set cryptmethod=blowfish2
catch /.*/
	" Vim 7.3+
	try
		set cryptmethod=blowfish
	catch /.*/
		" Vim 7.2-, neovim
	endtry
endtry
"   }}}
"    设置自动排版选项 {{{2
" 'formatoptions' 控制 Vim 如何对文本进行排版
" r 在插入模式按回车时，自动插入当前注释前导符。
" o 在普通模式按 'o' 或者 'O' 时，自动插入当前注释前导符。
" 2 在对文本排版时，将段落第二行而非第一行的缩进距离应用到其后的行上。
" m 可以在任何值高于 255 的多字节字符上分行。这对亚洲文本尤其有用，因为每
"   个字符都是单独的单位。
" B 在连接行时，不要在两个多字节字符之间插入空格。
" 1 不要在单字母单词后分行。如有可能，在它之前分行。
" j 在合适的场合，连接行时删除注释前导符。
" (使用 vim-sensible 中的设置，不在此处设置)
set formatoptions+=ro2mB1
" t 使用 'textwidth' 自动回绕文本
set formatoptions-=t
"   }}}
"   设置语法折叠 {{{2
"     使用说明 {{{3
"  可组合 {} () <> []使用
" zc 关闭当前打开的折叠
" zo 打开当前的折叠
" zm 关闭所有折叠
" zM 关闭所有折叠及其嵌套的折叠
" zr 打开所有折叠
" zR 打开所有折叠及其嵌套的折叠
" zd 删除当前折叠
" zE 删除所有折叠
" zj 移动至下一个折叠
" zk 移动至上一个折叠
" zn 禁用折叠
" zN 启用折叠
" 设置折叠层数为

" manual  手工定义折叠
" indent  更多的缩进表示更高级别的折叠
" expr    用表达式来定义折叠
" syntax  用语法高亮来定义折叠
" diff    对没有更改的文本进行折叠
" marker  对文中的标志折叠
"     }}}
" 允许折叠
set foldenable
set foldmethod=manual
" 设置折叠层数为
set foldlevel=0
" 设置折叠区域的宽度
set foldcolumn=0
"   }}}
" }}}

" 插件设置及其映射 {{{1
"   OpenRequireFile.vim {{{2
let g:OpenRequireFile_By_Map = [
	\ $HOME.'/Git/static_v3/src/js',
	\ $HOME.'/Git/static_v3/src/css'
	\ ]
" nmap <silent> <Leader>gf :call OpenRequireFile()<cr>
"   }}}
"   ag.vim {{{2
if s:hasAg
	let g:ag_prg="ag --vimgrep"
	let g:ag_working_path_mode="r"
" :Ag [options] pattern [directory]
" :Ag FooBar foo/**/*.py 等同于 :Ag -G foo/.*/[^/]*\.py$ FooBar
endif
"   }}}
"   vim-surround {{{2
" let g:surround_no_mappings = 1
" " original
" nmap ds  <Plug>Dsurround
" nmap ys  <Plug>Ysurround
" nmap yS  <Plug>YSurround
" nmap yss <Plug>Yssurround
" nmap ySs <Plug>YSsurround
" nmap ySS <Plug>YSsurround
" xmap S   <Plug>VSurround
" xmap gS  <Plug>VgSurround
" imap <C-G>s <Plug>Isurround
" imap <C-G>S <Plug>ISurround
" " cs is for cscope
" nmap cs <Plug>Csurround
"   }}}
"   vim-ragtag {{{2
let g:html_indent_script1 = "zero"
let g:html_indent_style1 = "zero"
"   }}}
"   vim-indent-guides 以灰色显示缩进块 {{{2
let g:indent_guides_start_level = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
" let g:indent_guides_color_change_percent = 3
if s:isGUI==0
	let g:indent_guides_auto_colors = 0
	function! s:indent_set_console_colors()
		highlight IndentGuidesOdd ctermbg = 235
		highlight IndentGuidesEven ctermbg = 236
	endfunction
	autocmd MyAutoCmd VimEnter,Colorscheme * call s:indent_set_console_colors()
endif
"   }}}
"   NERDCommenter {{{2
let NERDMenuMode = 0
let NERD_c_alt_style = 1
let NERDSpaceDelims = 1
"   }}}
"   NERDtree <Leader>tt {{{2
" 指定书签文件
let NERDTreeBookmarksFile = s:get_cache_dir("NERDTreeBookmarks")
" 同时改变当前工作目录
let NERDTreeChDirMode = 2
" NERDTree 替代 Netrw 插件来浏览本地目录
let NERDTreeHijackNetrw = 0
" 排除 . .. 文件
let NERDTreeIgnore = [ '__pycache__', '\.DS_Store', '\.bzr', '\.class', '\.git', '\.hg', '\.idea', '\.pyc', '\.pyo', '\.rvm', '\.sass-cache', '\.svn', '\.swo$', '\.swp$', '^\.$', '^\.\.$' ]
" 指定鼠标模式(1.双击打开 2.单目录双文件 3.单击打开)
let NERDTreeMouseMode = 2
" 打开文件后关闭树窗口
let NERDTreeQuitOnOpen = 1
" 是否默认显示书签列表
let NERDTreeShowBookmarks = 1
" 是否默认显示隐藏文件
let NERDTreeShowHidden = 1
" 窗口在加载时的宽度
let NERDTreeWinSize = 31

" 开关 NERDTree
nnoremap <silent> <Leader>tt :NERDTree<CR>
"   }}}
"   Tagbar (需安装ctags) {{{2
if s:hasCTags
	" 使 Tagbar 在左边窗口打开 (与 NERDTree 的位置冲突)
	" let tagbar_left = 1
	let tagbar_width = 30
	let tagbar_singleclick = 1
	augroup Filetype_Specific
		" autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx,*.ini call tagbar#autoopen()
		autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen()
		" 忽略 .user.js 和 JSON 格式文件
		autocmd BufReadPost *.user.js,*.json,*.jsonp let b:tagbar_ignore = 1
	augroup END

	nnoremap <silent> <Leader>tl :TagbarToggle<CR>
endif
"   }}}
"   NeoComplete {{{2
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Use camel case completion.
let g:neocomplete#enable_camel_case = 1
" Use fuzzy completion.
let g:neocomplete#enable_fuzzy_completion = 1
" 设置缓存目录
let g:neocomplete#data_directory = s:get_cache_dir("neocomplete")
let g:neocomplete#enable_auto_delimiter = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
" Set auto completion length.
let g:neocomplete#auto_completion_start_length = 2
" Set manual completion length.
let g:neocomplete#manual_completion_start_length = 0
" Set minimum keyword length.
let g:neocomplete#min_keyword_length = 3
" buffer file name pattern that disables neocomplete.
let g:neocomplete#sources#buffer#disabled_pattern = '\.log\|\.log\.\|.*quickrun.*\|\.cnx\|Log.txt\|\.user.js'
" buffer file name pattern that locks neocomplete. e.g. ku.vim or fuzzyfinder
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*\|\*unite\*\|Command Line'
let g:neocomplete#sources#buffer#cache_limit_size = 300000
let g:neocomplete#fallback_mappings = ["\<C-x>\<C-o>", "\<C-x>\<C-n>"]


" <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? '<C-n>' : '<TAB>'
"   }}}
"   Vim-AirLine {{{2
let g:airline_powerline_fonts = 0
let g:airline_left_sep=''
let g:airline_right_sep=''
" 修改排版方式
let g:airline#extensions#default#layout = [
  \ [ 'a', 'b', 'c' ],
  \ [ 'x', 'y', 'z']
  \ ]
let g:airline_section_c = '%<%n %F'
let g:airline_section_x = '%{strlen(&ft) ? &ft : "Noft"}%{&bomb ? " BOM" : ""}'
let g:airline_section_y = '%{&fileformat} %{(&fenc == "" ? &enc : &fenc)}'
let g:airline_section_z = '%2l:%-1v/%L'
" if !exists('g:airline_symbols')
	" let g:airline_symbols = {}
" endif
" 显示 Mode 的简称
let g:airline_mode_map = {
			\ '__' : '-',
			\ 'n'  : 'N',
			\ 'i'  : 'I',
			\ 'R'  : 'R',
			\ 'c'  : 'C',
			\ 'v'  : 'V',
			\ 'V'  : 'VL',
			\ '' : 'VB',
			\ 's'  : 'S',
			\ 'S'  : 'SL',
			\ '' : 'SB',
			\ }
" 定义符号
if s:isWindows
	let g:airline_symbols.whitespace = ""
endif
"   }}}
"   Emmet-Vim {{{2
let g:user_emmet_settings = { 'lang': "zh-cn" }
"   }}}
"   Ctrlp.vim <C-p> <Leader>{f,l,b} {{{2
let g:ctrlp_working_path_mode = 'ra'
" 设置缓存目录
let g:ctrlp_cache_dir = s:get_cache_dir("ctrlp")
let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn|cache|Trash)',
			\ 'file': '\v\.(log|jpg|png|jpeg|exe|so|dll|pyc|pyo|swf|swp|psd|db|DS_Store)$'
			\ }
if s:hasAg
	let g:ctrlp_user_command = 'ag %s -l --nogroup --column --smart-case --nocolor --follow --ignore "\.(git|hg|svn|bzr)$"'

	" ag is fast enough that CtrlP doesn't need to cache
	let g:ctrlp_use_caching = 0
else
	let g:ctrlp_custom_ignore = '\.(git|hg|svn|bzr)$'
	let g:ctrlp_user_command = {
			\ 'types': {
				\ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
				\ 2: ['.hg', 'hg --cwd %s locate -I .'],
			\ },
			\ 'fallback': 'find %s -type f'
		\ }
endif
let g:ctrlp_extensions = ['funky', 'tag', 'buffertag', 'quickfix', 'dir', 'rtscript', 'mixed']

let g:ctrlp_funky_syntax_highlight = 1
nnoremap <Leader>g :CtrlPFunky<Cr>
nnoremap <Leader>G :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

"     CtrlPBuffer中支持c-@关闭buffer {{{3
" (取自 https://github.com/kien/ctrlp.vim/issues/280 )
let g:ctrlp_buffer_func = { 'enter': 'CtrlPBDelete' }
function! CtrlPBDelete()
  nnoremap <buffer> <silent> <c-@> :call <sid>DeleteMarkedBuffers()<cr>
endfunction
function! s:DeleteMarkedBuffers()
	" list all marked buffers
	let marked = ctrlp#getmarkedlist()
	" the file under the cursor is implicitly marked
	if empty(marked)
		call add(marked, fnamemodify(ctrlp#getcline(), ':p'))
	endif
	" call bdelete on all marked buffers
	for fname in marked
		let bufid = fname =~ '\[\d\+\*No Name\]$' ? str2nr(matchstr(fname, '\d\+'))
					\ : fnamemodify(fname[2:], ':p')
		exec "silent! bdelete" bufid
	endfor
	" refresh ctrlp
	exec "normal \<F5>"
endfunction
"     }}}

nnoremap <silent> <Leader>m :CtrlPMRU<CR>
nnoremap <silent> <Leader>l :CtrlPLastMode<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <C-p> :CtrlP<Space>

" Enable omni completion.
augroup MyAutoCmd
	autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
	autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
	autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
	autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
	autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup END
" }}}
"   vim-dict {{{2
" <ctrl-x>_<ctrl-k> 打开提示
"   }}}
"   SudoEdit.vim {{{2
" :SudoRead[!] [file]
" :[range]SudoWrite[!] [file]
" :SudoUpDate [file]   以 root 权限保存文件
"   }}}
"   Windows 平台下窗口全屏组件 gvimfullscreen.dll {{{2
" 用于 Windows gVim 全屏窗口，可用 F11 切换
" 全屏后再隐藏菜单栏、工具栏、滚动条效果更好
"
" 映射          描述
" <F11>         切换全屏
" <Leader>ta    增加窗口透明度（[T]ransparency [A]dd）
" <Leader>tx    降低窗口透明度（与 Ctrl-A 及 Ctrl-X 相呼应）
" Alt-R         切换Vim是否总在最前面显示
" Vim 启动的时候自动使用当前颜色的背景色以去除 Vim 的白色边框
if s:isGUI && has('gui_win32') && has('libcall')
	let g:MyVimLib = 'gvimfullscreen.dll'
"     切换全屏函数 {{{3
	function! ToggleFullScreen()
		call libcall(g:MyVimLib, 'ToggleFullScreen', 1)
	endfunction
"     }}}
"     设置透明度函数 (Alpha值 默认:245 范围:180~255) {{{3
	let g:VimAlpha = 245
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
"     }}}
"     切换总在最前面显示函数 (默认禁用) {{{3
	let g:VimTopMost = 0
	function! SwitchVimTopMostMode()
		if g:VimTopMost == 0
			let g:VimTopMost = 1
		else
			let g:VimTopMost = 0
		endif
		call libcall(g:MyVimLib, 'EnableTopMost', g:VimTopMost)
	endfunction
"     }}}
"     映射 {{{3

	" 默认设置透明
	autocmd GUIEnter * call libcallnr(g:MyVimLib, 'SetAlpha', g:VimAlpha)
	" 增加 gVim 窗体的透明度 <Leader>ta
	nmap <silent> <Leader>ta :<C-U>call SetAlpha(-10)<cr>
	" 降低 gVim 窗体的透明度 <Leader>tx
	nmap <silent> <Leader>tx :<C-U>call SetAlpha(10)<cr>
	" 切换 gVim 是否在最前面显示
	nmap <silent> <M-r> :<C-U>call SwitchVimTopMostMode()<cr>
	" 切换全屏vim
	noremap <silent> <F11> :<C-U>call ToggleFullScreen()<cr>
"     }}}
endif
" }}}
"   Vim-JsBeautify <Leader>ff {{{2
let g:config_Beautifier = {
			\ "js"   : { "indent_size" : 4, "indent_style" : "tab" },
			\ "css"  : { "indent_size" : 4, "indent_style" : "tab" },
			\ "html" : { "indent_size" : 4, "indent_style" : "tab" }
			\ }
augroup Filetype_Specific
	" for css or scss
	autocmd FileType css,less,scss nnoremap <buffer> <Leader>ff :call CSSBeautify()<CR>
	autocmd FileType css,less,scss vnoremap <buffer> <Leader>ff :call RangeCSSBeautify()<CR>
	autocmd FileType html nnoremap <buffer> <Leader>ff :call HtmlBeautify()<CR>
	autocmd FileType html vnoremap <buffer> <Leader>ff :call RangeHtmlBeautify()<CR>
	autocmd FileType javascript,json nnoremap <buffer> <Leader>ff :call JsBeautify()<CR>
	autocmd FileType javascript,json vnoremap <buffer> <Leader>ff :call RangeJsBeautify()<CR>
augroup END
"   }}}
"   vim-multiple-cursors <C-{n,p,x}> {{{2
" <C-n> 选中下一个
" <C-p> 回退
" <C-x> 跳过
" <Esc> 退出
"   }}}
"   dash.vim <Leader>d {{{2
nmap <silent> <Leader>d <Plug>DashSearch
"   }}}
"   syntastic {{{2
" 光标跳转到第一个错误处
let g:syntastic_auto_jump = 2
if !s:isWindows && !s:isMac
	" let g:syntastic_error_symbol         = '✗'
	" let g:syntastic_style_error_symbol   = '✠'
	" let g:syntastic_warning_symbol       = '⚠'
	" let g:syntastic_style_warning_symbol = '≈'
	let g:syntastic_error_symbol         = "\u2717"
	let g:syntastic_style_error_symbol   = "\u2720"
	let g:syntastic_warning_symbol       = "\u26a0"
	let g:syntastic_style_warning_symbol = "\u2248"
endif
let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
let g:syntastic_mode_map = { 'mode': 'passive',
			\ 'active_filetypes': ['lua', 'php', 'sh'],
			\ 'passive_filetypes': ['puppet'] }
"   }}}
"   tern_for_vim.vim {{{
" 鼠标停留在方法内时显示参数提示
let g:tern_show_argument_hints = 'on_hold'
" 补全时显示函数类型定义
let g:tern_show_signature_in_pum = 1
" 跳转到浏览器
nnoremap <leader>tb :TernDocBrowse<cr>
" 显示变量定义
nnoremap <leader>tn :TernType<cr>
" 跳转到定义处
nnoremap <leader>tf :TernDef<cr>
" 显示文档
nnoremap <leader>td :TernDoc<cr>
" 预览窗口显示定义处代码
nnoremap <leader>tp :TernDefPreview<cr>
" 变量重命名
nnoremap <leader>tr :TernRename<cr>
" location 列表显示全部引用行
nnoremap <leader>ts :TernRefs<cr>
"   }}}
"   mark.vim {{{2
" 高亮光标下的单词
nmap <silent> <Leader>hl <plug>MarkSet
" 高亮选中的文本
vmap <silent> <Leader>hl <plug>MarkSet
" 高亮单词内：清除该单词的高亮  高亮单词外：清除所有的高亮
nmap <silent> <Leader>hh <plug>MarkAllClear
nmap <silent> <Leader>hr <plug>MarkRegex
vmap <silent> <Leader>hr <plug>MarkRegex
"  默认高亮配色 注意：urce后Mark会被覆盖
highlight MarkWord1  ctermbg=Cyan     ctermfg=Black  guibg=#8CCBEA    guifg=Black
highlight MarkWord2  ctermbg=Green    ctermfg=Black  guibg=#A4E57E    guifg=Black
highlight MarkWord3  ctermbg=Yellow   ctermfg=Black  guibg=#FFDB72    guifg=Black
highlight MarkWord4  ctermbg=Red      ctermfg=Black  guibg=#FF7272    guifg=Black
highlight MarkWord5  ctermbg=Magenta  ctermfg=Black  guibg=#FFB3FF    guifg=Black
highlight MarkWord6  ctermbg=Blue     ctermfg=Black  guibg=#9999FF    guifg=Black
"   }}}
" }}}
" 自动命令 {{{1
"   特殊文件类型自动命令组 {{{2
augroup Filetype_Specific
"     CSS {{{3
	autocmd FileType css setlocal smartindent noexpandtab foldmethod=indent
	autocmd BufNewFile,BufRead *.scss setlocal ft=scss
" 删除一条CSS中无用空格 <Leader>co
	autocmd FileType css vnoremap <Leader>co J:s/\s*\([{:;,]\)\s*/\1/g<CR>:let @/=''<CR>
	autocmd FileType css nnoremap <Leader>co :s/\s*\([{:;,]\)\s*/\1/g<CR>:let @/=''<CR>
"     }}}
"     Java {{{3
	" Java Velocity 模板使用html高亮
	autocmd BufNewFile,BufRead *.vm setlocal ft=vm syntax=html
"     }}}
"     JavaScript {{{3
"     }}}
"     PHP {{{3
	" PHP Twig 模板引擎语法
	autocmd BufNewFile,BufRead *.twig set syntax=twig
"     }}}
"     Python {{{3
	" Python 文件的一般设置，比如不要 tab 等
	autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab foldmethod=indent
"     }}}
"     VimFiles {{{3
	" 在VimScript中快速查找帮助文档
	autocmd Filetype vim noremap <buffer> <F1> <Esc>:help <C-r><C-w><CR>
	autocmd FileType vim setlocal foldmethod=indent keywordprg=:help
"     }}}
"     文本文件{{{3
	" pangu.vim
	autocmd BufWritePre *.markdown,*.md,*.text,*.txt call PanGuSpacing()
"     }}}
"     Quickfix {{{3
	autocmd FileType qf call AdjustWindowHeight(3, 50)
"     }}}
"     JavaScript {{{3
"     }}}
augroup END
"   }}}
"   默认自动命令组 {{{2
augroup MyAutoCmd
"     [Disable] 新建的文件，刚打开的文件不折叠 {{{3
	autocmd BufNewFile,BufRead * setlocal nofoldenable
"     }}}
"     当打开一个新缓冲区时，自动切换目录为当前编辑文件所在目录 {{{3
	autocmd BufEnter,BufNewFile,BufRead *
				\ if bufname("") !~ "^\[A-Za-z0-9\]*://" && expand("%:p") !~ "^sudo:"
				\|    silent! lcd %:p:h
				\|endif
"     }}}
	" 所有文件保存时自动删除多余空格 {{{3
	autocmd BufWritePre * call StripTrailingWhitespace()
"     }}}
"     自动更新Last Modified {{{3
	autocmd BufWritePre * call <SID>UpdateLastMod()
"     }}}
"     保存 Vim 配置文件后自动加载 {{{3
	" 加载完之后需要执行 AirlineRefresh 来刷新，否则 tabline 排版会乱
	" FIXME 似乎要 AirlineRefresh 两次才能完全刷新
	autocmd BufWritePost $MYVIMRC silent source $MYVIMRC | AirlineRefresh
"     }}}
"     禁止 NERDTree 在 Startify 页面打开一个分割窗口 {{{3
	autocmd User Startified setlocal buftype=
"     }}}
augroup END
"   }}}
" }}}
" 自定义令 {{{1
if has('user_commands')
"   :Delete 删除当前文件 {{{2
	command! -nargs=0 Delete
				\ if delete(expand('%'))
				\|    echohl WarningMsg
				\|    echo "删除当前文件失败!"
				\|    echohl None
				\|endif
"   }}}
"   :SQuote 将中文引号替换为英文引号 {{{2
	command! -range=% -bar SQuote <line1>,<line2>s/“\|”\|″/"/ge|<line1>,<line2>s/‘\|’\|′/'/ge
"   }}}
"   :SudoUpDate [file] 以 root 权限保存文件 {{{2
	" If the current buffer has never been saved, it will have no name,
	" call the file browser to save it, otherwise just save it.
	command! -nargs=0 -bar SudoUpDate
				\ if &modified
				\|    if !empty(bufname('%'))
				\|        exe 'SudoWrite'
				\|    endif
				\|endif
"   }}}
endif
" }}}
" 快捷键映射 {{{1
"   Alt 组合键不映射到菜单上 {{{2
set winaltkeys=no
"   }}}
"   回车时前字符为{时自动换行补全  {{{2
inoremap <silent> <CR> <C-R>=<SID>OpenSpecial('{','}')<CR>
"   }}}
"   N: 切换自动换行 <Shift+w> {{{2
nnoremap <s-w> :<C-U>call ToggleOption('wrap')<CR>
"   }}}
"   N: 复制文件路径 <Ctrl+c> {{{2
nnoremap <C-c> :let @* = expand('%:p')<cr>
"   }}}
"    N: Buffer切换 <Ctrl+{h,l,j,k}> {{{2
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
"   }}}
"   I: 移动光标 <Ctrl+{h,l,j,k}> {{{2
inoremap <c-h> <left>
inoremap <c-l> <right>
inoremap <c-j> <c-o>gj
inoremap <c-k> <c-o>gk
"   }}}
"   N: Buffers/Tab操作 <Shift+{h,l,j,k}> {{{2
nnoremap <s-h> :bprevious<cr>
nnoremap <s-l> :bnext<cr>
nnoremap <s-j> :tabnext<cr>
nnoremap <s-k> :tabprev<cr>
" nnoremap F :tabe %
"   }}}
"   N: 上下移动光标所在行 <Shift+{up,down}> {{{2
nmap <s-down> mz:m+<cr>`z
nmap <s-up> mz:m-2<cr>`z
"   }}}
"   V: 上下移动选中的行 <Shift+{up,down}> {{{2
vmap <s-down> :m'>+<cr>`<my`>mzgv`yo`z
vmap <s-up> :m'<-2<cr>`>my`<mzgv`yo`z
"   }}}
"   V: 全文搜索选中的文字 <Leader>{f,F} {{{2
" 向上查找
vnoremap <silent> <Leader>f y/<c-r>=escape(@", "\\/.*$^~[]")<cr><cr>
" 向下查找
vnoremap <silent> <Leader>F y?<c-r>=escape(@", "\\/.*$^~[]")<cr><cr>
"   }}}
"   N: 快速编辑 vimrc 文件 <Leader>e {{{2
nmap <Leader>e :tabedit $MYVIMRC<CR>
"   }}}
"   N: 混合语言文件快速切换类型 <Leader>{1,2,3,4} {{{2
nnoremap <Leader>1 :set filetype=xhtml<cr>
nnoremap <Leader>2 :set filetype=css<cr>
nnoremap <Leader>3 :set filetype=javascript<cr>
nnoremap <Leader>4 :set filetype=php<cr>
"   }}}
"   用空格键来开关折叠  {{{2
nnoremap <silent> <Space> @=((foldclosed(line('.')) < 0) ? 'zc':'zo')<CR>
"   }}}
"   打开光标下的链接 <Leader>ur {{{2
" (以下取自 https://github.com/lilydjwg/dotvim )
nmap <silent> <Leader>ur :call OpenURL()<CR>
"   }}}
"   切换绝对/相对行号 <Leader>nu {{{2
nnoremap <Leader>nu :<C-U>call ToggleOption('rnu')<CR>
"   }}}
"   使用Perl风格正则 {{{2
nnoremap / /\v
"   }}}
" }}}








" ===== 工作环境配制 =====
" Less to css   need npm install less -g {{{
function! LessToCss()
	let current_file = expand('%:p')
	let filename = fnamemodify(current_file, ':r') . ".css"
	let command = "!lessc '" . current_file . "' '" . filename ."'"
	"let command = "silent !lessc '" . current_file . "' '" . filename ."'"
	execute command
endfunction
"autocmd BufWritePost,FileWritePost *.less call LessToCss()
" }}}

"   加载 Vim 配置文件时让一些设置不再执行 {{{2
"  并记录加载 Vim 配置文件的次数
if !exists("g:VimrcIsLoad")
	let g:VimrcIsLoad = 1
else
	let g:VimrcIsLoad = g:VimrcIsLoad + 1
endif
" }}}
"   Vim Modeline: {{{2
" vim: fdm=marker fmr={{{,}}}  foldcolumn=1
" }}}
