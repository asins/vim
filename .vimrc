" Author: Asins - asinsimple AT gmail DOT com
"         Get latest vimrc from http://nootn.com/

set nocompatible " be iMproved
filetype off " required!

" 定义快捷键前缀，即<Leader>
let mapleader=","
let maplocalleader=","

" 删除原有自动命令，防止.vimrc执行多次时自动命令出现多次
autocmd!

"编辑vim配置文件
if has("unix")
	set fileformats=unix,mac,dos
	let $VIMFILES = $HOME."/.vim"
else
	set fileformats=dos,unix,mac
	let $VIMFILES = $VIM."/vimfiles"
endif

set rtp+=$VIMFILES/bundle/Vundle.vim
call vundle#begin($VIMFILES.'/bundle')

" let Vundle manage Vundle
" required!
Plugin 'gmarik/Vundle.vim'

" My Bundles here:
"Color
Plugin 'asins/vim-colors'

Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive'
Plugin 'bling/vim-airline'
Plugin 'kien/ctrlp.vim'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'jrhorn424/vim-multiple-cursors'

Plugin 'asins/vimcdoc'
Plugin 'asins/vim-dict'
Plugin 'rizzatti/dash.vim'

Plugin 'scrooloose/nerdcommenter'
Plugin 'asins/renamer.vim'
Plugin 'auto_mkdir'
Plugin 'majutsushi/tagbar'

" Syntax
Plugin 'othree/html5.vim'
Plugin 'othree/html5-syntax.vim'
Plugin 'hallison/vim-markdown'
Plugin 'pangloss/vim-javascript'
Plugin 'nono/jquery.vim'
Plugin 'groenewege/vim-less'

" Indent
Plugin 'IndentAnything'
Plugin 'jiangmiao/simple-javascript-indenter'


Plugin 'Shougo/neocomplete.vim'
"Bundle 'marijnh/tern_for_vim'
Plugin 'asins/mark'

" HTML tools
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-ragtag'
Plugin 'matchit.zip' " 通过%跳转配对代码
Plugin 'MatchTag' " HTML标签高亮配对
Plugin 'maksimr/vim-jsbeautify' "HTML/CSS/JS代码格式化

call vundle#end()
filetype plugin indent on

" encode
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,cp950,latin1

" font
set linespace=0
language messages zh_CN.UTF-8

set vb t_vb= "关闭响铃和闪屏

" 禁止显示滚动条
set guioptions-=r
set guioptions-=R
set guioptions-=L
set guioptions-=L

" 禁止显示菜单和工具条
set guioptions-=T "gui的工具栏
set guioptions-=m "gui的菜单

set showtabline=0 "Tab栏
set laststatus=2 " 默认显示状态栏

"set nocursorline
set guifont=Monaco:h14

" 显示状态栏 (默认值为 1, 无法显示状态栏)
"set laststatus=2
" 设置在状态行显示的信息
"set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ [%{(&fenc==\"\"?&enc:&fenc).(&bomb?\",BOM\":\"\")}]\ %c:%l/%L%)

syntax on " 自动语法高亮
set nobackup " Close backup
set nowritebackup
set autochdir  " 自动切换当前目录为当前文件所在的目录
set ignorecase  " 搜索时忽略大小写，但在有一个或以上大写字母时仍大小写敏感
set nowrapscan " 搜索到文件两端时不重新搜索
set incsearch  " 实时搜索
set hlsearch  " 搜索时高亮显示被找到的文本
set mouse=a " 允许在所有模式下使用鼠标
set number   " 显示行号
set hidden    " 允许在有未保存的修改时切换缓冲区
set wildmenu " Vim自身命令行模式智能补全
set smartindent " 智能自动缩进
set scrolloff=3  " 上下可视行数
set nocursorline  " 不突出显示当前行
set showmatch  "显示括号配对情况
set shortmess=atl  "启动时不显示 捐赠提示
set helplang=cn
" Display extra whitespace
set list listchars=tab:\|\ ,trail:.,extends:>,precedes:<

" Tab
set tabstop=4 " 设定 tab 长度为 4
set softtabstop=4 " 设置按BackSpace的时候可以一次删除掉4个空格
set shiftwidth=4  " 设定 << 和 >> 命令移动时的宽度为 4
set smarttab
set noexpandtab " 使用Tab而非空格
set backspace=indent,eol,start    " 让退格键和 Delete 键支持删除回车符

if has("unix")
	set transparency=4 " 设置透明度
endif

"set foldenable 开启代码折叠功能
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

" 新建的文件，刚打开的文件不折叠
autocmd BufNewFile,BufRead * setlocal nofoldenable list

" Filetype
autocmd BufRead,BufNewFile *.json set filetype=json

" 保存时自动删除多余空格
fun! StripTrailingWhitespace()
	" Preparation: save last search, and cursor position.
	let _s=@/
	let l = line(".")
	let c = col(".")
	" do the business:
	%s/$\|\s\+$//e
	" clean up: restore previous search history, and cursor position
	let @/=_s
	call cursor(l, c)
endfun
autocmd BufWritePre * call StripTrailingWhitespace()


" ===== 插件配置 =====

" dict {{{
"<ctrl-x>_<ctrl-k> 打开提示
autocmd filetype javascript setlocal dictionary+=$VIMFILES/bundle/vim-dict/dict/javascript.dic
autocmd filetype javascript setlocal dictionary+=$VIMFILES/bundle/vim-dict/dict/node.dic
autocmd filetype css setlocal dictionary+=$VIMFILES/bundle/vim-dict/dict/css.dic
autocmd filetype php setlocal dictionary+=$VIMFILES/bundle/vim-dict/dict/php.dic
" }}}

" {{{ ragtag HTML/XML缩进
let g:html_indent_script1 = "zero"
let g:html_indent_style1 = "zero"
" }}}

" {{{ emmet HTML代码生成
" 常用命令可看：http://nootn.com/blog/Tool/23/
let g:user_emmet_settings = {
			\ 'lang': "zh-cn"
			\ }
" <c-y>m  合并多行
" }}}

" {{{ NERDtree 文件管理器
" 让Tree把自己给装饰得多姿多彩漂亮点
let NERDChristmasTree=1
" 控制当光标移动超过一定距离时，是否自动将焦点调整到屏中心
let NERDTreeAutoCenter=1
" 指定书签文件
let NERDTreeBookmarksFile=$VIMFILES.'\NERDTree_bookmarks'
" 指定鼠标模式(1.双击打开 2.单目录双文件 3.单击打开)
let NERDTreeMouseMode=2
" 是否默认显示书签列表
let NERDTreeShowBookmarks=1
" 是否默认显示文件
let NERDTreeShowFiles=1
" 是否默认显示行号
let NERDTreeShowLineNumbers=0
" 窗口位置（'left' or 'right'）
let NERDTreeWinPos='left'
" 窗口宽度
let NERDTreeWinSize=31
nnoremap <Leader>tt :NERDTree<CR>
"}}}

" {{{ The-NERD-Commenter 注释代码用的，以下映射已写在插件中
let NERDMenuMode = 0
" <Leader>ca 在可选的注释方式之间切换，比如C/C++ 的块注释/* */和行注释//
" <Leader>cc 注释当前行
" <Leader>cs 以”性感”的方式注释
" <Leader>cA 在当前行尾添加注释符，并进入Insert模式
" <Leader>cu 取消注释
" <Leader>cm 添加块注释
" }}}

" {{{ vim-jsbeautify  need nodejs 优化html/js/js代码，并不是简单的缩进噢
let g:config_Beautifier = {
			\ "js" : {
				\ "indent_size" : 4,
				\ "indent_style" : "tab"
				\ },
			\ "css" : {
				\ "indent_size" : 4,
				\ "indent_style" : "tab"
				\ },
			\ "html" : {
				\ "indent_size" : 4,
				\ "indent_style" : "tab"
				\ }
			\ }
autocmd FileType javascript noremap <silent> <Leader>js :call JsBeautify()<cr>
autocmd FileType html noremap <silent> <Leader>js :call HtmlBeautify()<cr>
autocmd FileType css,less noremap <silent> <Leader>js :call CSSBeautify()<cr>
" }}}

" {{{ matchit.zip 对%命令进行扩展使得能在嵌套标签和语句之间跳转
" % 正向匹配      g% 反向匹配
" [% 定位块首     ]% 定位块尾
"}}}

" {{{ MatchTag HTML标签高亮配对
" }}}

" {{{ asins/renamer.vim 文件重命名
" :Renamer 将当前文件所在文件夹下的内容显示在一个新窗口
" :Ren 开始重命名
"}}}

" {{{ Mark 给各种tags标记不同的颜色，便于观看调式的插件。
" 在运行source后Mark会被覆盖
hi MarkWord1  ctermbg=Cyan     ctermfg=Black  guibg=#8CCBEA    guifg=Black
hi MarkWord2  ctermbg=Green    ctermfg=Black  guibg=#A4E57E    guifg=Black
hi MarkWord3  ctermbg=Yellow   ctermfg=Black  guibg=#FFDB72    guifg=Black
hi MarkWord4  ctermbg=Red      ctermfg=Black  guibg=#FF7272    guifg=Black
hi MarkWord5  ctermbg=Magenta  ctermfg=Black  guibg=#FFB3FF    guifg=Black
hi MarkWord6  ctermbg=Blue     ctermfg=Black  guibg=#9999FF    guifg=Black

nmap <silent> <Leader>hl <plug>MarkSet
vmap <silent> <Leader>hl <plug>MarkSet
nmap <silent> <Leader>hh <plug>MarkClear
nmap <silent> <Leader>hr <plug>MarkRegex
vmap <silent> <Leader>hr <plug>MarkRegex
" }}}

" {{{ tagbar
nmap <silent> <Leader>tl :TagbarToggle<CR>
"let g:tagbar_ctags_bin = '/usr/local/Cellar/ctags/5.8/bin/ctags'
" }}}

" vim-airline {{{
nmap <silent> <Leader>r :AirlineRefresh<CR>
let g:airline_theme='badwolf'
let g:airline_powerline_fonts=0
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_mode_map = {
			\ '__' : '-',
			\ 'n'  : 'N',
			\ 'i'  : 'I',
			\ 'R'  : 'R',
			\ 'c'  : 'C',
			\ 'v'  : 'V',
			\ 'V'  : 'V',
			\ '' : 'V',
			\ 's'  : 'S',
			\ 'S'  : 'S',
			\ '' : 'S',
			\ }
let g:airline#extensions#default#layout = [
  \ [ 'a', 'b', 'c' ],
  \ [ 'x', 'y', 'z']
  \ ]
let g:airline_section_c = '%<%n %F'
let g:airline_section_x = '%{strlen(&ft) ? &ft : "Noft"}%{&bomb ? " BOM" : ""}'
let g:airline_section_y = '%{&fileformat} %{(&fenc == "" ? &enc : &fenc)}'
let g:airline_section_z = '%2l:%-1v/%L'
" }}}

" {{{ Code Completins
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? '<C-n>' : '<TAB>'
" }}}

" ctrlp.vim {{{
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn|cache|Trash)',
			\ 'file': '\v\.(log|jpg|png|jpeg|exe|so|dll|pyc|pyo|swf|swp|psd|db)$'
			\ }

" funky extension - jump to funciton defs
let g:ctrlp_extensions = ['funky']
let g:ctrlp_funky_syntax_highlight = 1
"let g:ctrlp_buftag_ctags_bin = '/usr/local/Cellar/ctags/5.8/bin/ctags'
nnoremap <Leader>g :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <Leader>G :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

nnoremap <silent> <Leader>f :CtrlPMRU<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <C-P> :CtrlP<Space>
" }}}

" {{{ vim-multiple-cursors 光标选择功能
"let g:multi_cursor_next_key='<C-n>'
"let g:multi_cursor_prev_key='<C-p>'
"let g:multi_cursor_skip_key='<C-x>'
"let g:multi_cursor_quit_key='<Esc>'
" }}}

" {{{ Dash.vim for mac os
nmap <silent> <leader>d <Plug>DashSearch
" }}}


" ===== 键盘映射(非插件) =====

" 快速编辑.vimrc文件
nmap <Leader>e :tabedit $MYVIMRC<CR>

" 自动运用设置
autocmd BufWritePost .vimrc,.gvimrc,_vimrc silent source %

" 窗口切换
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k

" Buffers/Tab操作快捷方式!
nnoremap <s-h> :bprevious<cr>
nnoremap <s-l> :bnext<cr>
nnoremap <s-j> :tabnext<cr>
nnoremap <s-k> :tabprev<cr>
"nnoremap F :tabe %

" 插入模式下上下左右移动光标
inoremap <c-h> <left>
inoremap <c-l> <right>
inoremap <c-j> <c-o>gj
inoremap <c-k> <c-o>gk

" 一些不错的映射转换语法（如果在一个文件中混合了不同语言时有用）
nnoremap <Leader>1 :set filetype=xhtml<cr>
nnoremap <Leader>2 :set filetype=css<cr>
nnoremap <Leader>3 :set filetype=javascript<cr>
nnoremap <Leader>4 :set filetype=php<cr>

" 代码垂直移动
nmap <s-down> mz:m+<cr>`z
nmap <s-up> mz:m-2<cr>`z
vmap <s-down> :m'>+<cr>`<my`>mzgv`yo`z
vmap <s-up> :m'<-2<cr>`>my`<mzgv`yo`z

" 全文搜索选中的文字
vnoremap <silent> <Leader>f y/<c-r>=escape(@", "\\/.*$^~[]")<cr><cr>
vnoremap <silent> <Leader>F y?<c-r>=escape(@", "\\/.*$^~[]")<cr><cr>

" 普通模式下 Shift+W 切换自动换行
nnoremap <s-w> :exe &wrap==1 ? 'set nowrap' : 'set wrap'<cr>

" 普通模式下 Ctrl+c 复制文件路径
nnoremap <c-c> :let @* = expand('%:p')<cr>

" 在VimScript中快速查找帮助文档
autocmd Filetype vim noremap <buffer> <F1> <Esc>:help <C-r><C-w><CR>


" ===== 工作环境配制 =====
" {{{ TUDOU 打开项目中的文件
function! GetOsPortUrl(url) " 格式化地址分隔线
	if has("unix") || has('mac')
		let extra = ':p:gs?\\?/?'
	else
		let extra = ':p:gs?/?\\?'
	end
	return fnamemodify(a:url, extra)
endfunction
" 获取项目目录
function! GetProjectPath(path, filename)
	let path = fnamemodify(a:path, ':p:h')
	let path = findfile(a:filename, '.;')
	if(path == '')
		echo 'Not find project directory.'
	endif
	return fnamemodify(path, ':h')
endfunction
" 打开@import 'xx/oo.less' 'xxx/oo'(less形式) 'xx/oo.css'
function! GetLessImportFile()
	let prefpath = GetProjectPath('%', 'tpm-config.js').'\src\css\'
	let filePath = substitute(getline('.'), '@import\s\+"\([^"]\+\)";\?', '\1', '')
	if strridx(filePath, './') == 0 " 相对引入
		let fullPath = expand('%:p:h') . substitute(filePath, '^\.', '', '')
	else " 绝对引入
		let fullPath = prefpath . filePath
	endif
	let fullPath = GetOsPortUrl(fullPath)
	let fullPath = substitute(fullPath, '\/$', '', '')
	if fnamemodify(fullPath, ':e') == ''
		let fullPath = fullPath . '.less'
	endif
	execute ":e " fullPath
	if findfile(fullPath) == ""
		echo 'File not exist, Create now: '. fullPath
	endif
endfunction
" 打开Require 引入的JS文件  './xxx'   'model/xxx' 'ooo/xxx.js' '../model/xxx'
function! GetRequireFile()
	let prefpath = GetProjectPath('%', 'tpm-config.js').'\src\js\'
	let filePath = GetFilePath()
	if strridx(filePath, './') != -1 " 相对引入
		let fullPath = expand('%:p:h') . '/' . filePath
	else " 绝对引入
		let fullPath = prefpath . filePath
	endif
	let fullPath = GetOsPortUrl(fullPath)
	let fullPath = substitute(fullPath, '\/$', '', '')
	if fnamemodify(fullPath, ':e') == ''
		let fullPath = fullPath . '.js'
	endif

	execute ":e " fullPath
	if findfile(fullPath) == ""
		echo 'File not exist, Create now: '. fullPath
	endif
endfunction
function! GetFilePath()
	let line = substitute(expand('<cWORD>'), "'", '"', "g")
	let mlist = matchlist(line, '.*\"\(.\+\)\".*')
	if len(mlist) > 0
		return mlist[1]
	else
		let line = substitute(getline('.'), "'", '"', "g")
		let mlist = matchlist(line, '.*\"\(.\+\)\".*')
		if len(mlist) > 0
			return mlist[1]
		endif
	endif
	return ''
endfunction
function! OpenRequireFile()
	if strridx(getline('.'), '@import') >= 0
		call GetLessImportFile()
	else
		call GetRequireFile()
	endif
endfunction
nmap <silent> <Leader>gf :call OpenRequireFile()<cr>

function! YtpmVM(filePath, env)
	"let s:cmt = '!ytpm vm "'.a:filePath.'" '.a:env.' --config="'.$HOME.'/Git/static_v3/tpm-config.js"'
	let s:cmt = '!ytpm vm "'.a:filePath.'" '.a:env.' --config="'.$HOME.'/Git/mall/tpm-config.js"'
	"echo s:cmt
	exe s:cmt
endfunction
autocmd BufRead,BufNewFile *.vm setlocal ft=vm syntax=html
autocmd filetype vm noremap <Leader>ywt :call YtpmVM('%', 'wwwtest')<cr>
autocmd filetype vm noremap <Leader>ywt1 :call YtpmVM('%', 'wwwtest1')<cr>
autocmd filetype vm noremap <Leader>ywt2 :call YtpmVM('%', 'wwwtest2')<cr>
autocmd filetype vm noremap <Leader>ybt :call YtpmVM('%', 'beta')<cr>
autocmd filetype vm noremap <Leader>yde :call YtpmVM('%', 'dev')<cr>
autocmd filetype vm noremap <Leader>ytt :call YtpmVM('%', 'test')<cr>
" }}}

" need npm install less -g
function! LessToCss()
	let current_file = expand('%:p')
	let filename = fnamemodify(current_file, ':r') . ".css"
	let command = "!lessc '" . current_file . "' '" . filename ."'"
	"let command = "silent !lessc '" . current_file . "' '" . filename ."'"
	execute command
endfunction
"autocmd BufWritePost,FileWritePost *.less call LessToCss()
