" Title: 	Vim library for ATP filetype plugin.
" Author:	Marcin Szamotulski
" Email:	mszamot [AT] gmail [DOT] com
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin
" Language:	tex

" Open Function:
 "{{{1 atplib#tools#Open
 " a:1	- pattern or a file name
 " 		a:1 is regarded as a filename if filereadable(pattern) is non
 " 		zero.
function! atplib#tools#Open(bang, dir, TypeDict, ...)
    if a:dir == "0"
	echohl WarningMsg 
	echomsg "You have to set g:atp_LibraryPath in your vimrc or atprc file." 
	echohl None
	return
    endif

    let pattern = ( a:0 >= 1 ? a:1 : "") 
    let file	= filereadable(pattern) ? pattern : ""

    if file == ""
	if a:bang == "!" || !exists("g:atp_Library")
	    let g:atp_Library 	= filter(split(globpath(a:dir, "*"), "\n"), 'count(keys(a:TypeDict), fnamemodify(v:val, ":e"))')
	    let found 		= deepcopy(g:atp_Library) 
	else
	    let found		= deepcopy(g:atp_Library)
	endif
	call filter(found, "fnamemodify(v:val, ':t') =~ pattern")
	" Resolve symlinks:
	call map(found, "resolve(v:val)")
	" Remove double entries:
	call filter(found, "count(found, v:val) == 1")
	if len(found) > 1
	    echohl Title 
	    echo "Found files:"
	    echohl None
	    let i = 1
	    for file in found
		if len(map(copy(found), "v:val =~ escape(fnamemodify(file, ':t'), '~') . '$'")) == 1
		    echo i . ") " . fnamemodify(file, ":t")
		else
		    echo i . ") " . pathshorten(fnamemodify(file, ":p"))
		endif
		let i+=1
	    endfor
	    let choice = input("Which file to open? ")-1
	    if choice == -1
		return
	    endif
	    let file = found[choice]
	elseif len(found) == 1
	    let file = found[0]
	else
	    echohl WarningMsg
	    echomsg "[ATP:] Nothing found."
	    echohl None
	    return
	endif
    endif

    let ext 	= fnamemodify(file, ":e")
    let viewer 	= get(a:TypeDict, ext, 0) 

    if viewer == '0'
	echomsg "\n"
	echomsg "[ATP:] filetype: " . ext . " is not supported, add an entry to g:atp_OpenTypeDict" 
	return
    endif
    if viewer !~ '^\s*cat\s*$' && viewer !~ '^\s*g\=vim\s*$' && viewer !~ '^\s*edit\s*$' && viewer !~ '^\s*tabe\s*$' && viewer !~ '^\s*split\s*$'
	call system(viewer . " '" . file . "' &")  
    elseif viewer =~ '^\s*g\=vim\s*$' || viewer =~ '^\s*tabe\s*$'
	exe "tabe " . fnameescape(file)
	setl nospell
    elseif viewer =~ '^\s*edit\s*$' || viewer =~ '^\s*split\s*$'
	exe viewer . " " . fnameescape(file)
	setl nospell
    elseif viewer == '^\s*cat\s*'
	redraw!
	echohl Title
	echo "cat '" . file . "'"
	echohl None
	echo system(viewer . " '" . file . "' &")  
    endif
"     if fnamemodify(file, ":t") != "" && count(g:atp_open_completion, fnamemodify(file, ":t")) == 0
" 	call extend(g:atp_open_completion, [fnamemodify(file, ":t")], 0)
"     endif
    " This removes the hit Enter vim prompt. 
    call feedkeys("<CR>")
    return
endfunction
"}}}1

" Labels Tools: GrepAuxFile, SrotLabels, generatelabels and showlabes.
" {{{1 LABELS
" the argument should be: resolved full path to the file:
" resove(fnamemodify(bufname("%"),":p"))

" {{{2 --------------- atplib#tools#GrepAuxFile
" This function searches in aux file (actually it tries first ._aux file,
" made by compile.py - this is because compile.py is copying aux file only if
" there are no errors (for to not affect :Labels command)
function! atplib#tools#GrepAuxFile(...)
    " Aux file to read:

    let base = ( a:0 >= 1 ? fnamemodify(a:1, ":r") : fnamemodify(b:atp_MainFile, ":r") ) 
    let aux_filename	= base."._aux"
    if !filereadable(aux_filename)
	let aux_filename	= a:1
	if !filereadable(a:1) && exists("b:atp_MainFile")
	    let aux_filename = fnamemodify(atplib#FullPath(b:atp_MainFile), ":r") . "._aux"
	    if !filereadable(aux_filename)
		let aux_filename = fnamemodify(atplib#FullPath(b:atp_MainFile), ":r") . ".aux"
	    else
		echoerr "[ATP] aux file not found (atplib#tools#GrepAuxFile)."
	    endif
	endif
    endif

    let tex_filename	= fnamemodify(aux_filename, ":r") . ".tex"

    if !filereadable(aux_filename)
	" We should worn the user that there is no aux file
	" /this is not visible ! only after using the command 'mes'/
	echohl WarningMsg
	echomsg "[ATP:] there is no aux file. Run ".b:atp_TexCompiler." first."
	echohl None
	return []
	" CALL BACK is not working
	" I can not get output of: vim --servername v:servername --remote-expr v:servername
	" for v:servername
	" Here we should run latex to produce auxfile
" 	echomsg "Running " . b:atp_TexCompiler . " to get aux file."
" 	let labels 	= system(b:atp_TexCompiler . " -interaction nonstopmode " . atp_MainFile . " 1&>/dev/null  2>1 ; " . " vim --servername ".v:servername." --remote-expr 'atplib#tools#GrepAuxFile()'")
" 	return labels
    endif
"     let aux_file	= readfile(aux_filename)

    let saved_llist	= getloclist(0)
    if bufloaded(aux_filename)
	exe "silent! bd! " . bufnr(aux_filename)
    endif
    try
	silent execute 'lvimgrep /\\newlabel\s*{/j ' . fnameescape(aux_filename)
    catch /E480:/
    endtry
    let loc_list	= getloclist(0)
    call setloclist(0, saved_llist)
    call map(loc_list, ' v:val["text"]')

    let labels		= []
    if g:atp_debugGAF
	let g:gaf_debug	= {}
    endif

    " Equation counter depedns on the option \numberwithin{equation}{section}
    " /now this only supports article class.
    let equation = len(atplib#search#GrepPreambule('^\s*\\numberwithin{\s*equation\s*}{\s*section\s*}', tex_filename))
"     for line in aux_file
    for line in loc_list
    if line =~ '\\newlabel\>'
	" line is of the form:
	" \newlabel{<label>}{<rest>}
	" where <rest> = {<label_number}{<title>}{<counter_name>.<counter_number>}
	" <counter_number> is usually equal to <label_number>.
	"
	" Document classes: article, book, amsart, amsbook, review:
	" NEW DISCOVERY {\zs\%({[^}]*}\|[^}]\)*\ze} matches for inner part of 
	" 	{ ... { ... } ... }	/ only one level of being recursive / 
	" 	The order inside the main \%( \| \) is important.
	"This is in the case that the author put in the title a command,
	"for example \mbox{...}, but not something more difficult :)
	if line =~ '^\\newlabel{[^}]*}{{[^}]*}{[^}]*}{\%({[^}]*}\|[^}]\)*}{[^}]*}'
	    let label	= matchstr(line, '^\\newlabel\s*{\zs[^}]*\ze}')
	    let rest	= matchstr(line, '^\\newlabel\s*{[^}]*}\s*{\s*{\zs.*\ze}\s*$')
	    let l:count = 1
	    let i	= 0
	    while l:count != 0 
		let l:count = ( rest[i] == '{' ? l:count+1 : rest[i] == '}' ? l:count-1 : l:count )
		let i+= 1
	    endwhile
	    let number	= substitute(strpart(rest,0,i-1), '{\|}', '', 'g')  
	    let rest	= strpart(rest,i)
	    let rest	= substitute(rest, '^{[^}]*}{', '', '')
	    let l:count = 1
	    let i	= 0
	    while l:count != 0 
		let l:count = rest[i] == '{' ? l:count+1 : rest[i] == '}' ? l:count-1 : l:count 
		let i+= 1
	    endwhile
	    let counter	= substitute(strpart(rest,i-1), '{\|}', '', 'g')  
	    let counter	= strpart(counter, 0, stridx(counter, '.')) 

	" Document classes: article, book, amsart, amsbook, review
	" (sometimes the format is a little bit different)
	elseif line =~ '\\newlabel{[^}]*}{{\d\%(\d\|\.\)*{\d\%(\d\|\.\)*}}{\d*}{\%({[^}]*}\|[^}]\)*}{[^}]*}'
	    let list = matchlist(line, 
		\ '\\newlabel{\([^}]*\)}{{\(\d\%(\d\|\.\)*{\d\%(\d\|\.\)*\)}}{\d*}{\%({[^}]*}\|[^}]\)*}{\([^}]*\)}')
	    let [ label, number, counter ] = [ list[1], list[2], list[3] ]
	    let number	= substitute(number, '{\|}', '', 'g')
	    let counter	= matchstr(counter, '^\w\+')

	" Document class: article
	elseif line =~ '\\newlabel{[^}]*}{{\d\%(\d\|\.\)*}{\d\+}}'
	    let list = matchlist(line, '\\newlabel{\([^}]*\)}{{\(\d\%(\d\|\.\)*\)}{\d\+}}')
	    let [ label, number, counter ] = [ list[1], list[2], "" ]

	" Memoir document class uses '\M@TitleReference' command
	" which doesn't specify the counter number.
	elseif line =~ '\\M@TitleReference' 
	    let label	= matchstr(line, '^\\newlabel\s*{\zs[^}]*\ze}')
	    let number	= matchstr(line, '\\M@TitleReference\s*{\zs[^}]*\ze}') 
	    let counter	= ""

	elseif line =~ '\\newlabel{[^}]*}{.*\\relax\s}{[^}]*}{[^}]*}}'
	    " THIS METHOD MIGHT NOT WORK WELL WITH: book document class.
	    let label 	= matchstr(line, '\\newlabel{\zs[^}]*\ze}{.*\\relax\s}{[^}]*}{[^}]*}}')
	    let nc 		= matchstr(line, '\\newlabel{[^}]*}{.*\\relax\s}{\zs[^}]*\ze}{[^}]*}}')
	    let counter	= matchstr(nc, '\zs\a*\ze\(\.\d\+\)\+')
	    let number	= matchstr(nc, '.*\a\.\zs\d\+\(\.\d\+\)\+') 
	    if counter == 'equation' && !equation
		let number = matchstr(number, '\d\+\.\zs.*')
	    endif

	" aamas2010 class
	elseif line =~ '\\newlabel{[^}]*}{{\d\%(\d\|.\)*{\d\%(\d\|.\)*}{[^}]*}}' && atplib#search#DocumentClass(b:atp_MainFile) =~? 'aamas20\d\d'
	    let label 	= matchstr(line, '\\newlabel{\zs[^}]*\ze}{{\d\%(\d\|.\)*{\d\%(\d\|.\)*}{[^}]*}}')
	    let number 	= matchstr(line, '\\newlabel{\zs[^}]*\ze}{{\zs\d\%(\d\|.\)*{\d\%(\d\|.\)*\ze}{[^}]*}}')
	    let number	= substitute(number, '{\|}', '', 'g')
	    let counter	= ""

	" subeqautions
	elseif line =~ '\\newlabel{[^}]*}{{[^}]*}{[^}]*}}'
	    let list 	= matchlist(line, '\\newlabel{\([^}]*\)}{{\([^}]*\)}{\([^}]*\)}}')
	    let [ label, number ] = [ list[1], list[2] ]
	    let counter	= ""

	" AMSBook uses \newlabel for tocindent
	" which we filter out here.
	elseif line =~ '\\newlabel{[^}]*}{{\d\+.\?{\?\d*}\?}{\d\+}}'
	    let list 	= matchlist(line,  '\\newlabel{\([^}]*\)}{{\(\d\+.\?{\?\d*}\?\)}{\(\d\+}\)}')
	    let [ label, number ] = [ list[1], list[2] ]
	    let number 	= substitute(number, '\%({\|}\)', '', 'g')
	    let counter 	= ""
	else
	    let label	= "nolabel: " . line
	endif

	if label !~ '^nolabel:\>'
	    let number = substitute(number, '{\|}', '', 'g')
	    call add(labels, [ label, number, counter])
	    if g:atp_debugGAF
		call extend(g:gaf_debug, { label : [ number, counter ] })
	    endif
	endif
    endif
    endfor

    return labels
endfunction
" }}}2
" Sorting function used to sort labels.
" {{{2 --------------- atplib#tools#SortLabels
" It compares the first component of lists (which is line number)
" This should also use the bufnr.
function! atplib#tools#SortLabels(list1, list2)
    if a:list1[0] == a:list2[0]
	return 0
    elseif str2nr(a:list1[0]) > str2nr(a:list2[0])
	return 1
    else
	return -1
    endif
endfunction
" }}}2
" Function which find all labels and related info (label number, lable line
" number, {bufnr} <= TODO )
" {{{2 --------------- atplib#tools#generatelabels
" This function runs in two steps:
" 	(1) read lables from aux files using GrepAuxFile()
" 	(2) search all input files (TreeOfFiles()) for labels to get the line
" 		number 
" 	   [ this is done using :vimgrep which is fast, when the buffer is not loaded ]
function! atplib#tools#generatelabels(filename, ...)
    let s:labels	= {}
    let bufname		= fnamemodify(a:filename,":t")
    let auxname		= fnamemodify(a:filename,":p:r") . ".aux"
    let return_ListOfFiles	= a:0 >= 1 ? a:1 : 1

    let true=1
    let i=0

    let aux_labels	= atplib#tools#GrepAuxFile(auxname)

    let saved_pos	= getpos(".")
    call cursor(1,1)

    let [ TreeOfFiles, ListOfFiles, TypeDict, LevelDict ] 		= TreeOfFiles(a:filename)
    let ListOfFiles_orig = copy(ListOfFiles)
    if count(ListOfFiles, a:filename) == 0
	call add(ListOfFiles, a:filename)
	let TypeDict[a:filename] = "input"
    endif
    let saved_llist	= getloclist(0)
    call setloclist(0, [])

    " Look for labels in all input files.
    for file in ListOfFiles
	if get(TypeDict, file, 'input') == 'input'
	    let file	= atplib#FullPath(file)
	    silent! execute "keepjumps lvimgrepadd /\\label\s*{/j " . fnameescape(file)
	endif
    endfor
    let loc_list	= getloclist(0)
"     call setloclist(0, saved_llist)
    call map(loc_list, '[ v:val["lnum"], v:val["text"], v:val["bufnr"] ]')

    let labels = {}

    for label in aux_labels
	let dict		= filter(copy(loc_list), "v:val[1] =~ '\\label\s*{\s*'.escape(label[0], '*\/$.') .'\s*}'")
	let line		= get(get(dict, 0, []), 0, "") 
	let bufnr		= get(get(dict, 0, []), 2, "")
	let bufname		= fnamemodify(bufname(bufnr), ":p")
	if get(labels, bufname, []) == []
	    let labels[bufname] = [ [line, label[0], label[1], label[2], bufnr ] ]
	else
	    call add(labels[bufname], [line, label[0], label[1], label[2], bufnr ]) 
	endif
    endfor

    for bufname in keys(labels)
	call sort(labels[bufname], "atplib#tools#SortLabels")
    endfor

"     let i=0
"     while i < len(texfile)
" 	if texfile[i] =~ '\\label\s*{'
" 	    let lname 	= matchstr(texfile[i], '\\label\s*{.*', '')
" 	    let start 	= stridx(lname, '{')+1
" 	    let lname 	= strpart(lname, start)
" 	    let end	= stridx(lname, '}')
" 	    let lname	= strpart(lname, 0, end)
"     "This can be extended to have also the whole environment which
"     "could be shown.
" 	    call extend(s:labels, { i+1 : lname })
" 	endif
" 	let i+=1 
"     endwhile

    if exists("t:atp_labels")
	call extend(t:atp_labels, labels, "force")
    else
	let t:atp_labels	= labels
    endif
    keepjumps call setpos(".", saved_pos)
    if return_ListOfFiles
	return [ t:atp_labels, ListOfFiles_orig ]
    else
	return t:atp_labels
    endif
endfunction
" }}}2
" This function opens a new window and puts the results there.
" {{{2 --------------- atplib#tools#showlabels
" the argument is [ t:atp_labels, ListOfFiles ] 
" 	where ListOfFiles is the list returne by TreeOfFiles() 
function! atplib#tools#showlabels(labels)

    " the argument a:labels=t:atp_labels[bufname("")] !
    let l:cline=line(".")

    let saved_pos	= getpos(".")

    " Open new window or jump to the existing one.
    let l:bufname	= bufname("")
    let l:bufpath	= fnamemodify(resolve(fnamemodify(bufname("%"),":p")),":h")
    let BufFullName	= fnamemodify(l:bufname, ":p") 

    let l:bname="__Labels__"

    let t:atp_labelswinnr=winnr()
    let t:atp_labelsbufnr=bufnr("^".l:bname."$")
    let l:labelswinnr=bufwinnr(t:atp_labelsbufnr)

    let tabstop	= 0
    for file in a:labels[1]
	let dict	= get(a:labels[0], file, [])
	let tabstop	= max([tabstop, max(map(copy(dict), "len(v:val[2])")) + 1])
	unlet dict
    endfor
"     let g:labelswinnr	= l:labelswinnr
    let saved_view	= winsaveview()

    if l:labelswinnr != -1
	" Jump to the existing window.
	redraw
	exe l:labelswinnr . " wincmd w"
	if l:labelswinnr != t:atp_labelswinnr
	    silent exe "%delete"
	else
	    echoerr "ATP error in function s:showtoc, TOC/LABEL buffer 
		    \ and the tex file buffer agree."
	    return
	endif
    else

    " Open new window if its width is defined (if it is not the code below
    " will put lab:cels in the current buffer so it is better to return.
	if !exists("t:atp_labels_window_width")
	    echoerr "t:atp_labels_window_width not set"
	    return
	endif

	" tabstop option is set to be the longest counter number + 1
	redraw
	let toc_winnr=bufwinnr(bufnr("__ToC__"))
	if toc_winnr == -1
	    let l:openbuffer= "keepalt " . t:atp_labels_window_width . "vsplit +setl\\ tabstop=" . tabstop . "\\ nowrap\\ buftype=nofile\\ filetype=toc_atp\\ syntax=labels_atp __Labels__"
	else
	    exe toc_winnr."wincmd w"
	    let l:openbuffer= "keepalt below split +setl\\ tabstop=".tabstop."\\ nowrap\\ buftype=nofile\\ filetype=toc_atp\\ syntax=labels_atp __Labels__"
	endif
	silent exe l:openbuffer
	silent call atplib#setwindow()
	let t:atp_labelsbufnr=bufnr("")
    endif
    unlockvar b:atp_Labels
    let b:atp_Labels	= {}

"     let g:labels=copy(a:labels)

    let line_nr	= 2
    for file in a:labels[1]
	if !(len(get(a:labels[0], file, []))>0)
	    continue
	endif
	call setline("$", fnamemodify(file, ":t") . " (" . fnamemodify(file, ":h")  . ")")
	call extend(b:atp_Labels, { 1 : [ file, 0 ]})
	for label in get(a:labels[0], file, [])
	    " Set line in the format:
	    " /<label_numberr> \t[<counter>] <label_name> (<label_line_nr>)/
	    " if the <counter> was given in aux file (see the 'counter' variable in atplib#tools#GrepAuxFile())
	    " print it.
	    " /it is more complecated because I want to make it as tight as
	    " possible and as nice as possible :)
	    " the first if checks if there are counters, then counter type is
	    " printed, then the tabs are set./
    " 	let slen	= winwidth(0)-tabstop-5-5
    " 	let space_len 	= max([1, slen-len(label[1])])
	    if tabstop+(len(label[3][0])+3)+len(label[1])+(len(label[0])+2) < winwidth(0)
		let space_len	= winwidth(0)-(tabstop+(len(label[3][0])+3)+len(label[1])+(len(label[0])+2))
	    else
		let space_len  	= 1
	    endif
	    let space	= join(map(range(space_len), '" "'), "")
	    let set_line 	= label[2] . "\t[" . label[3][0] . "] " . label[1] . space . "(" . label[0] . ")"
	    call setline(line_nr, set_line ) 
	    call extend(b:atp_Labels, { line_nr : [ file, label[0] ]}) 
	    let line_nr+=1
	endfor
    endfor
    lockvar 3 b:atp_Labels

    " set the cursor position on the correct line number.
    call search(l:bufname, 'w')
    let l:number=1
    for label  in get(a:labels[0], BufFullName, [])
	if l:cline >= label[0]
	    keepjumps call cursor(line(".")+1, col("."))
	elseif l:number == 1 && l:cline < label[0]
	    keepjumps call cursor(line(".")+1, col("."))
	endif
	let l:number+=1
    endfor
endfunction
" }}}2
" }}}1

" Table Of Contents Tools:
function! atplib#tools#getlinenr(...) "{{{
    let line 	=  a:0 >= 1 ? a:1 : line('.')
    let labels 	=  a:0 >= 2 ? a:2 : expand("%") == "__Labels__" ? 1 : 0

    if labels == 0
	let bnr = bufnr("__ToC__")
	if len(getbufvar(bnr, "atp_Toc"))
	    return get(getbufvar(bnr, "atp_Toc"), line, ["", ""])[1]
	endif
    else
	let bnr = bufnr("__Labels__")
	let dict=getbufvar(bnr, "atp_Labels")
	if len(dict)
	    return get(dict, line, ["", ""])[1]
	endif
    endif
endfunction "}}}
function! atplib#tools#CursorLine() "{{{
    if exists("t:cursorline_idmatch")
	try
	    call matchdelete(t:cursorline_idmatch)
	catch /E803:/
	endtry
    endif
    if atplib#tools#getlinenr(line(".")) 
	let t:cursorline_idmatch =  matchadd('CursorLine', '^\%'.line(".").'l.*$')
    endif
endfunction "}}}
" vim:fdm=marker:ff=unix:noet:ts=8:sw=4:fdc=1
