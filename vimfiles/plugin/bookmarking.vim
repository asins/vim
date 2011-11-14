" ==============================================================================
"        File: bookmarking.vim
"      Author: David Terei <davidterei@gmail.com>
"		    URL: 
" Last Change: Wed Jul 6 19:21:14 EST 2010
"     Version: 2.1
"     License: Distributed under the Vim charityware license.
"     Summary: A bookmaking facility to Vim for marking points of interest.
"
" GetLatestVimScripts: 3022 1 :AutoInstall: bookmarking.vim
"
" Description:
" Add a book marking feature to Vim that allows lines of interest to be marked.
" While similar to marks, you don't need to assign a bookmark to a mark key,
" instead an infinite number of bookmarks can be created and then jumped
" through in sequential order (by line number) with no strain on your memory.
" This is great to use when you are browsing through some source code for the
" first time and need to mark out places of interest to learn how it works.
"
" Installation:
" Normally, this file will reside in your plugins directory and be
" automatically sourced. No changes to your .vimrc are needed unless you want
" to change some default settings.
"
" Uses:
" The bookmark facility provides a number of new commands as well as a default
" mapping of these commands to keys. This mapping can be customised as can the
" bookmarks appearance.
"
" Commands available (with keyboard shortcuts in brackets):
"  * Use the command 'ToggleBookmark' to set or remove a bookmark. (<F3>)
"  * Use the command 'NextBookmark' to jump to the next bookmark. (<F4>)
"  * Use the command 'PreviousBookmark' to jump to the previous bookmark. (<F5>)
"
" Settings:
" The keyboard mapping of the commands can be easily changed by adding new
" mappings to them in your .vimrc. If a mapping is defined in your .vimrc
" then the default mappings won't be added.
"
" You can also alter the appearance of the bookmark itself. The bookmark is
" shown on the screen using Vim's sign feature. To define the sign used for a
" bookmark yourself, include a sign definition in your .vimrc for a sign
" called 'bookmark'.
"
" Examples:
" In your .vimrc:
"
"     map <silent> bb :ToggleBookmark<CR>
"     map <silent> bn :NextBookmark<CR>
"     map <silent> bp :PreviousBookmark<CR>
"
"     define bookmark text=>>
"
" History:
"   Wed Jul 6, 2010 - 2.1:
"     * Fixed bug where the script only worked for files with a '.' in their
"       names
"
"   Wed Jul 6, 2010 - 2.0:
"     * Huge amount of bugs fixed, previous version was pretty broken.
"     * Added new ClearBookmarks command, to clear all bookmarks.
"
"   Fri Mar 19, 2010 - 1.0:
"     * Initial release.
"

" Allow disabling and stop reloading
if exists("loaded_bookmarks")
  finish
endif
let loaded_bookmarks = 1

hi BookMarkHighLight guifg=#7F9845 guibg=#232526

" save and change cpoptions
let s:save_cpo = &cpo
set cpo&vim

" The sign to use for the bookmark
try
	" Don't define if already defined by user
	sign list bookmark
catch
	" default sign
    "设置被标记行的文字颜色
	sign define bookmark text=-> texthl=BookMarkHighLight
endtry

" Key Mappings
if !hasmapto(':ToggleBookmark')
	map <silent> <F9> :ToggleBookmark<CR>
endif

if !hasmapto(':NextBookmark')
	map <silent> <F4> :NextBookmark<CR>
endif

if !hasmapto(':PreviousBookmark')
	map <silent> <S-F4> :PreviousBookmark<CR>
endif

" Menu mapping
noremenu <script> Plugin.Bookmark\ Toggle   s:toggleBookmark
noremenu <script> Plugin.Bookmark\ Next     s:nextBookmark
noremenu <script> Plugin.Bookmark\ Previous s:previousBookmark

" Numeric sort comparator
function s:numericalCompare(i1, i2)
	return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc

" This function creates or destroys a bookmark
function s:toggleBookmark()
	if (!exists("b:bookmarks"))
		" create data structures if first run

		" store bookmark locations
		let b:bookmarks = []
		" store bookmark ids (to map to signs), mapping from
		" bookmarks to bookmarkIDs is done by index number
		let b:bookmarkIDs = []
		" unique ID generator
		let b:nextBookmarkID = 1
	endif

	" new data structures to copy into
	let newbookmarks = []
	let newbookmarkIDs = []

	" bookmark id to remove if any
	let remove = 0
	let cpos = line(".")

	" we copy since we are looping over
	let i = 0
	while i < len(b:bookmarks)
		if (cpos == b:bookmarks[i])
			let remove = b:bookmarkIDs[i]
		else
			let newbookmarks = add(newbookmarks, b:bookmarks[i])
			let newbookmarkIDs = add(newbookmarkIDs, b:bookmarkIDs[i])
		endif
		let i = i + 1
	endwhile

	" create a bookmark
	if (!remove)
		" get a new unique id
		let id = b:nextBookmarkID
		let b:nextBookmarkID = b:nextBookmarkID + 1

		" insert into list of bookmarks and ids, we keep bookmarks in sorted
		" order
		let i = 0
		while i < len(b:bookmarks)
			if (cpos < b:bookmarks[i])
				call insert(b:bookmarks, cpos, i)
				call insert(b:bookmarkIDs, id, i)
				break
			endif
			let i = i + 1
		endwhile
		
		" if end of list and nothing bigger found
		if (i == len(b:bookmarks))
			let b:bookmarks = add(b:bookmarks, cpos)
			let b:bookmarkIDs = add(b:bookmarkIDs, id)
		endif

		" place actual sign now
		exe "sign place ".id." line=".cpos." name=bookmark buffer=".bufnr("%")
		let b:endoffile = line("$")
	else
		" remove a bookmark
		let b:bookmarks = newbookmarks
		let b:bookmarkIDs = newbookmarkIDs
		exe "sign unplace ".remove." buffer=".bufnr("%")
	endif
endfunction

command ToggleBookmark :call <SID>toggleBookmark()

" This function clears all bookmarks
function s:clearBookmarks()
	if (!exists("b:bookmarks") || empty(b:bookmarks))
		return
	endif

	" clear all signs
	for bid in b:bookmarkIDs
		exe "sign unplace ".bid." buffer=".bufnr("%")
	endfor

	" clear all data structures
	let b:bookmarks = []
	let b:bookmarkIDs = []
	let b:nextBookmarkID = 1
endfunction

command ClearBookmarks :call <SID>clearBookmarks()

" This function keeps the bookmarks in sync with changes to the file
function s:keepUpdateBooks()
	if (!exists("b:bookmarks") || empty(b:bookmarks) || !exists("b:endoffile"))
		return
	endif

	" collect change info
	let epos = line("$")
	let cpos = line("'.")
	let dif = b:endoffile - epos
	let b:endoffile = epos

	" if some change, need to loop through all book marks and either leave them
	" (if before change), delete them (if in the change) or decrease the line
	" number (if after change)
	if (dif != 0)
		let newbookmarks = []
		let newbookmarkIDs = []
		let i = 0
		while i < len(b:bookmarks)
			let bpos = b:bookmarks[i]
			if ((cpos <= bpos) && (bpos <= (cpos + dif - 1)))
				let id = b:bookmarkIDs[i]
				exe "sign unplace ".id." buffer=".bufnr("%")
			elseif (bpos >= cpos)
				let newbookmarks = add(newbookmarks, bpos - dif)
				let newbookmarkIDs = add(newbookmarkIDs, b:bookmarkIDs[i])
			else
				let newbookmarks = add(newbookmarks, bpos)
				let newbookmarkIDs = add(newbookmarkIDs, b:bookmarkIDs[i])
			endif
			let i = i + 1
		endwhile
		let b:bookmarks = newbookmarks
		let b:bookmarkIDs = newbookmarkIDs
	endif
endfunction

" Need to bind the update function to the changes autocommand
autocmd! CursorMoved,CursorMovedI * :call <SID>keepUpdateBooks()

" jump to next (by line number) bookmark
function s:nextBookmark()
	if (!exists("b:bookmarks") || empty(b:bookmarks))
		return
	endif

	let cpos = line(".")
	for bpos in b:bookmarks
		if (cpos < bpos)
			exe "normal! ".bpos."G"
			echo
			return
		endif
	endfor

	" none found so wrap
	if (len(b:bookmarks) >= 1)
		exe "normal! ".b:bookmarks[0]."G"
		echoh WarningMsg | echom "bookmarking hit BOTTOM, continuing at TOP"
			\| echoh None
	endif
endfunction

command NextBookmark :call <SID>nextBookmark()

" jump to previous (by line number) bookmark
function s:previousBookmark()
	if (!exists("b:bookmarks") || empty(b:bookmarks))
		return
	endif

	let cpos = line(".")
	let index = len(b:bookmarks) - 1
	while index >= 0
		let bpos = b:bookmarks[index]
		if (bpos < cpos)
			exe "normal! ".bpos."G"
			echo
			return
		endif
		let index = index - 1
	endwhile

	" none found so wrap
	if (len(b:bookmarks) >= 1)
		exe "normal! ".b:bookmarks[len(b:bookmarks) - 1]."G"
		echoh WarningMsg | echom "bookmarking hit TOP, continuing at BOTTOM"
			\| echoh None
	endif
endfunction

command PreviousBookmark :call <SID>previousBookmark()

" restore cpoptions to original
let &cpo = s:save_cpo

