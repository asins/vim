## 自行编译方法

我编译使用的是VC2010的环境，可自行查找可用的绿色编译包。bigvim.bat中的内容

```text
nmake -f Make_mvc.mak GUI=yes FEATURES=HUGE MBYTE=yes IME=yes GIME=yes DYNAMIC_IME=yes OLE=yes PYTHON=c:\python27 DYNAMIC_PYTHON=yes PYTHON_VER=27 PYTHON3=c:\python33 DYNAMIC_PYTHON3=yes PYTHON3_VER=33 %1 CSCOPE=yes DEBUG=no
```

## 插件列表

我的VIM插件完全使用`Vundle`进行管理。

``` vim
Bundle 'gmarik/vundle'
Bundle 'asins/vimcdoc'
Bundle 'asins/vim-dict'
Bundle 'asins/vim-colors'
Bundle 'tpope/vim-vividchalk'
Bundle 'chriskempson/vim-tomorrow-theme'
Bundle 'othree/html5.vim'
Bundle 'nono/jquery.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'python.vim--Vasiliev'
Bundle 'xml.vim'
Bundle 'tpope/vim-markdown'
Bundle 'lepture/vim-css'
Bundle 'Shougo/neocomplcache'
Bundle 'honza/snipmate-snippets'
Bundle 'Shougo/neosnippet'
Bundle 'vim-scripts/upAndDown'
Bundle 'tpope/vim-ragtag'
Bundle 'ZenCoding.vim'
Bundle 'groenewege/vim-less'
Bundle 'IndentAnything'
Bundle 'Javascript-Indentation'
Bundle 'gg/python.vim'
Bundle 'teramako/jscomplete-vim'
Bundle 'asins/template.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'vim-scripts/bufexplorer.zip'
Bundle 'The-NERD-tree'
Bundle 'The-NERD-Commenter'
Bundle 'auto_mkdir'
Bundle 'mru.vim'
Bundle 'majutsushi/tagbar'
Bundle 'CmdlineComplete'
Bundle 'colorizer'
Bundle 'asins/jsbeautify'
Bundle 'asins/renamer.vim'
Bundle 'mikeage/ShowMarks'
Bundle 'ctrlp.vim'
Bundle 'matchit.zip'
Bundle 'MatchTag'
Bundle 'Mark'
```

## 特殊的dll文件

  - gvimext.dll是修改过后的，功能简化了，当选择单个文件时右键菜单只会出现一个 "Edit with VIM"，当选择多个文件同时会多出个"Diff with VIM"，同时加入了图标。
  - gvimfullscreen.dll是个相当全的东西，能让VIM全屏、透明、总在最前功能，在vimrc中设置如下则可使用，重的修改是去除Gvim的白边！[源代码](http://github.com/asins/gvimfullscreen_win32)可到这里找到。

``` vim
" {{{ Win平台下窗口全屏组件 gvimfullscreen.dll
" Alt + Enter 全屏切换
" Shift + t 降低窗口透明度
" Shift + y 加大窗口透明度
" Shift + r 切换Vim是否总在最前面显示
" Vim启动的时候自动使用当前颜色的背景色以去除Vim的白色边框
if has('gui_running') && has('gui_win32') && has('libcall')
    let g:MyVimLib = 'gvimfullscreen.dll'
    function! ToggleFullScreen()
        call libcall(g:MyVimLib, 'ToggleFullScreen', 1)
    endfunction

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

    let g:VimTopMost = 0
    function! SwitchVimTopMostMode()
        if g:VimTopMost == 0
            let g:VimTopMost = 1
        else
            let g:VimTopMost = 0
        endif
        call libcall(g:MyVimLib, 'EnableTopMost', g:VimTopMost)
    endfunction
    "映射 Alt+Enter 切换全屏vim
    map <a-enter> <esc>:call ToggleFullScreen()<cr>
    "切换Vim是否在最前面显示
    nmap <s-r> <esc>:call SwitchVimTopMostMode()<cr>
    "增加Vim窗体的不透明度
    nmap <s-t> <esc>:call SetAlpha(10)<cr>
    "增加Vim窗体的透明度
    nmap <s-y> <esc>:call SetAlpha(-10)<cr>
    " 默认设置透明
    autocmd GUIEnter * call libcallnr(g:MyVimLib, 'SetAlpha', g:VimAlpha)
endif
" }}}
```


## 更新记录

### Update 2014-07-04

 - 加入CtrlP插件用于在项目中查找文件等功能
 - 删除 bufexplorer.vim 使用CtrlP的:CtrlPBuffer
 - 删除 mra.vim 使用CtrlP的:CtrlPMRU
 - 替换原有Mark插件 解决source _vimrc标记颜色丢失问题，相应快捷键也更新了
 - 用airline替换powerline，运行速度更快
 - 删除neocomplete中对默认字典的定义解决无法提示字典词的问题

现在开始使用OS X系统，所以有些设置做了微调以解决与系统默认设置冲突的问题。

#### Update 2013-03-26

修改vim编译文件(src\feature.h)，去除toolbar/menu包。注释掉了所有包括以下字符的行

``` vim
# define FEAT_MENU
# define FEAT_TOOLBAR
```

编译完后使用时出现些问题

* 在_vimrc中去掉了`"source $VIMRUNTIME/delmenu.vim`这行。
* NERD-Commenter插件没有对是否加载了menu包做判断！在vimrc中加入一行`let NERDMenuMode = 0`。

修改vim源码，修复Win下右下角白边bug

* 在`src/gui_w32.c` 文件中第 1516行 `CreateWindowEx` 这个API中的第一个参数  `WS_EX_CLIENTEDGE` 把它改为0。
* 在`src/gui_w32.c` 文件中第1567行 `gui.border_offset = gui.border_width + 2;` 这个把 +2 去掉。
* `gvimfullscreen.c`文件中第112行 `SetWindowLong(hTextArea, GWL_EXSTYLE, GetWindowLong(hTextArea, GWL_EXSTYLE) | WS_EX_CLIENTEDGE);` 这行注释掉。

#### Update 2013-03-22

这次编译只支持Python3.3、Python2.7，其它的都去除了，用不上，最后补丁为875

#### Update 2012-10-24

插件管理交给`Vundle`管理了，其中我也改动了几个插件也放在Git中。更新插件时直接`:BundleInstall`就可以了（但修改完后得重启GVIM再执行命令），不用的插件在`_vimrc`中删除后执行`:BundleClean`就可以了。

#### Update 2011-11-09

从git中更新后编译的64位GVIM，支持Python3.2、Python2.7、Perl、TCL/TC应该算是挺全的了，补丁的到353。

修改了一行源码，用于解决GVIM白边的问题，因为我使用的配色为`molokai`，所以给的颜色是黑色的。

~~修改 gui_w32.c  第 1471 行.~~

    wndclassw.hbrBackground = CreateSolidBrush(RGB(27, 29, 30));
