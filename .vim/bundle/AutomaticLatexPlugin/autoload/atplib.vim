" Title: 	Vim library for ATP filetype plugin.
" Author:	Marcin Szamotulski
" Email:	mszamot [AT] gmail [DOT] com
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin
" Language:	tex

" Source ATPRC File:
function! atplib#ReadATPRC() "{{{
    if ( has("unix") || has("max") || has("macunix") )
	" Note: in $HOME/.atprc file the user can set all the local buffer
	" variables without using autocommands
	"
	" Note: it must be sourced at the begining because some options handle
	" how atp will load (for example if we load history or not)
	" It also should be run at the end if the user defines mapping that
	" should be overwrite the ATP settings (this is done via
	" autocommand).
	let atprc_file=get(split(globpath($HOME, '.atprc.vim', 1), "\n"), 0, "")
	if !filereadable(atprc_file)
	    let atprc_file = get(split(globpath(&rtp, "**/ftplugin/ATP_files/atprc.vim"), '\n'), 0, "")
	endif
	if filereadable(atprc_file)
	    execute 'source ' . fnameescape(atprc_file)
	endif
    else
	let atprc_file = get(split(globpath(&rtp, "**/ftplugin/ATP_files/atprc.vim"), '\n'), 0, "")
	if filereadable(atprc_file)
	    execute 'source ' . fnameescape(atprc_file)
	endif
    endif
endfunction "}}}
" Kill:
function! atplib#KillPIDs(pids,...) "{{{
    if len(a:pids) == 0 && a:0 == 0
	return
    endif
python << END
import os, signal
from signal import SIGKILL
pids=vim.eval("a:pids")
for pid in pids:
    try:
	os.kill(int(pid),SIGKILL)
    except OSError:
        pass
END
endfunction "}}}
" Write:
function! atplib#write(...) "{{{
    let backup		= &backup
    let writebackup	= &writebackup
    let project		= b:atp_ProjectScript

    " In this way lastchange plugin will work better (?):
"     let eventignore 	= &eventignore
"     setl eventigonre	+=BufWritePre

    " Disable WriteProjectScript
    let b:atp_ProjectScript = 0
    set nobackup
    set nowritebackup

    if a:0 > 0 && a:1 == "silent"
	silent! update
    else
	update
    endif

    let b:atp_ProjectScript = project
    let &backup		= backup
    let &writebackup	= writebackup
"     let &eventignore	= eventignore
endfunction "}}}
" Log:
function! atplib#Log(file, string, ...) "{{{1
    if finddir(g:atp_TempDir, "/") == ""
	call mkdir(g:atp_TempDir, "p", 0700)
    endif
    if a:0 >= 1
	call delete(g:atp_TempDir."/".a:file)
    else
	exe "redir >> ".g:atp_TempDir."/".a:file 
	silent echo a:string
	redir END
    endif
endfunction "}}}1

"Make g:atp_TempDir, where log files are stored.
"{{{1
function! atplib#TempDir() 
    " Return temporary directory, unique for each user.
if has("python")
function! ATP_SetTempDir(tmp)
    let g:atp_TempDir=a:tmp
endfunction
python << END
import vim, tempfile, os
USER=os.getenv("USER")
tmp=tempfile.mkdtemp(suffix="", prefix="atp_")
vim.eval("ATP_SetTempDir('"+tmp+"')")
END
delfunction ATP_SetTempDir
else
    let g:atp_TempDir=substitute(tempname(), '\d\+$', "atp_debug", '')
    call mkdir(g:atp_TempDir, "p", 0700)
endif
endfunction
"}}}1
" Outdir: append to '/' to b:atp_OutDir if it is not present. 
function! atplib#outdir() "{{{1
    if has("win16") || has("win32") || has("win64") || has("win95")
	if b:atp_OutDir !~ "\/$"
	    let b:atp_OutDir=b:atp_OutDir . "\\"
	endif
    else
	if b:atp_OutDir !~ "\/$"
	    let b:atp_OutDir=b:atp_OutDir . "/"
	endif
    endif
    return b:atp_OutDir
endfunction
"}}}1
" Return {path} relative to {rel}, if not under {rel} return {path}
function! atplib#RelativePath(path, rel) "{{{1
    let current_dir 	= getcwd()
    exe "lcd " . fnameescape(a:rel)
    let rel_path	= fnamemodify(a:path, ':.')
    exe "lcd " . fnameescape(current_dir)
    return rel_path
endfunction
"}}}1
" Return fullpath
function! atplib#FullPath(file_name) "{{{1
    let cwd = getcwd()
    if a:file_name =~ '^\s*\/'
	let file_path = a:file_name
    elseif exists("b:atp_ProjectDir")
	try
	    exe "lcd " . fnameescape(b:atp_ProjectDir)
	    let file_path = fnamemodify(a:file_name, ":p")
	    exe "lcd " . fnameescape(cwd)
	catch /E344:/
	    let file_path = fnamemodify(a:file_name, ":p")
	endtry
    else
	let file_path = fnamemodify(a:file_name, ":p")
    endif
    return file_path
endfunction
"}}}1
" Table:
"{{{ atplibTable, atplib#FormatListinColumns, atplib#PrintTable
function! atplib#Table(list, spaces)
" take a list of lists and make a list which is nicely formated (to echo it)
" spaces = list of spaces between columns.
    "maximal length of columns:
    let max_list=[]
    let new_list=[]
    for i in range(len(a:list[0]))
	let max=max(map(deepcopy(a:list), "len(v:val[i])"))
	call add(max_list, max)
    endfor

    for row in a:list
	let new_row=[]
	let i=0
	for el in row
	    let new_el=el.join(map(range(max([0,max_list[i]-len(el)+get(a:spaces,i,0)])), "' '"), "")
	    call add(new_row, new_el)
	    let i+=1
	endfor
	call add(new_list, new_row)
    endfor

    return map(new_list, "join(v:val, '')")
endfunction 
function! atplib#FormatListinColumns(list,s)
    " take a list and reformat it into many columns
    " a:s is the number of spaces between columns
    " for example of usage see atplib#PrintTable
    let max_len=max(map(copy(a:list), 'len(v:val)'))
    let new_list=[]
    let k=&l:columns/(max_len+a:s)
    let len=len(a:list)
    let column_len=len/k
    for i in range(0, column_len)
	let entry=[]
	for j in range(0,k)
	    call add(entry, get(a:list, i+j*(column_len+1), ""))
	endfor
	call add(new_list,entry)
    endfor
    return new_list
endfunction 
" Take list format it with atplib#FormatListinColumns and then with
" atplib#Table (which makes columns of equal width)
function! atplib#PrintTable(list, spaces)
    " a:list 	- list to print
    " a:spaces 	- nr of spaces between columns 

    let list = atplib#FormatListinColumns(a:list, a:spaces)
    let nr_of_columns = max(map(copy(list), 'len(v:val)'))
    let spaces_list = ( nr_of_columns == 1 ? [0] : map(range(1,nr_of_columns-1), 'a:spaces') )

    return atplib#Table(list, spaces_list)
endfunction
"}}}

" QFLength "{{{
function! atplib#qflength() 
    let lines = 1
    " i.e. open with one more line than needed.
    for qf in getqflist()
	let text=substitute(qf['text'], '\_s\+', ' ', 'g')
	let lines+=(len(text))/&l:columns+1
    endfor
    return lines
endfunction "}}}

function! atplib#Let(varname, varvalue)
    exe "let ".substitute(string(a:varname), "'", "", "g")."=".substitute(string(a:varvalue), "''\\@!", "", "g")
endfunction

" IMap Functions:
" {{{
" These maps extend ideas from TeX_9 plugin:
" With a:1 = "!" (bang) remove texMathZoneT (tikzpicture from MathZones).
function! atplib#IsInMath(...)
    let line		= a:0 >= 2 ? a:2 : line(".")
    let col		= a:0 >= 3 ? a:3 : col(".")-1
    if a:0 > 0 && a:1 == "!"
	let atp_MathZones=filter(copy(g:atp_MathZones), "v:val != 'texMathZoneT'")
    else
	let atp_MathZones=copy(g:atp_MathZones)
    endif
    call filter(atp_MathZones, 'v:val !~ ''\<texMathZone[VWXY]\>''')
    if atplib#complete#CheckSyntaxGroups(['texMathZoneV', 'texMathZoneW', 'texMathZoneX', 'texMathZoneY'])
	return 1
    else
	return atplib#complete#CheckSyntaxGroups(atp_MathZones, line, col) && 
		    \ !atplib#complete#CheckSyntaxGroups(['texMathText'], line, col)
    endif
endfunction
function! atplib#MakeMaps(maps, ...)
    let aucmd = ( a:0 >= 1 ? a:1 : '' )
    for map in a:maps
	if map[3] != "" && ( !exists(map[5]) || {map[5]} > 0 || 
		    \ exists(map[5]) && {map[5]} == 0 && aucmd == 'InsertEnter'  )
	    if exists(map[5]) && {map[5]} == 0 && aucmd == 'InsertEnter'
		exe "let ".map[5]." =1"
	    endif
	    exe map[0]." ".map[1]." ".map[2].map[3]." ".map[4]
	endif
    endfor
endfunction
function! atplib#DelMaps(maps)
    for map in a:maps
	let cmd = matchstr(map[0], '[^m]\ze\%(nore\)\=map') . "unmap"
	let arg = ( map[1] =~ '<buffer>' ? '<buffer>' : '' )
	try
	    exe cmd." ".arg." ".map[2].map[3]
	catch /E31:/
	endtry
    endfor
endfunction
" From TeX_nine plugin:
function! atplib#IsLeft(lchar,...)
    let nr = ( a:0 >= 1 ? a:1 : 0 )
    let left = getline('.')[col('.')-2-nr]
    if left ==# a:lchar
	return 1
    else
	return 0
    endif
endfunction
" try
function! atplib#ToggleIMaps(var, augroup, ...)
    if exists("s:isinmath") && 
		\ ( atplib#IsInMath() == s:isinmath ) &&
		\ ( a:0 >= 2 && a:2 ) &&
		\ a:augroup == 'CursorMovedI'
	return
    endif

    call SetMathVimOptions()

    if atplib#IsInMath() 
	call atplib#MakeMaps(a:var, a:augroup)
    else
	call atplib#DelMaps(a:var)
	if a:0 >= 1 && len(a:1)
	    call atplib#MakeMaps(a:1)
	endif
    endif
    let s:isinmath = atplib#IsInMath() 
endfunction
" catch E127
" endtry "}}}

" Toggle On/Off Completion 
" {{{1 atplib#OnOffComp
function! atplib#OnOffComp(ArgLead, CmdLine, CursorPos)
    return filter(['on', 'off'], 'v:val =~ "^" . a:ArgLead') 
endfunction
"}}}1

" Find Vim Server: find server 'hosting' a file and move to the line.
" {{{1 atplib#FindAndOpen
" Can be used to sync gvim with okular.
" just set in okular:
" 	settings>okular settings>Editor
" 		Editor		Custom Text Editor
" 		Command		gvim --servername GVIM --remote-expr "atplib#FindAndOpen('%f','%l', '%c')"
" You can also use this with vim but you should start vim with
" 		vim --servername VIM
" and use servername VIM in the Command above.		
function! atplib#ServerListOfFiles()
    exe "redir! > " . g:atp_TempDir."/ServerListOfFiles.log"
    let file_list = []
    for nr in range(1, bufnr('$')-1)
	" map fnamemodify(v:val, ":p") is not working if we are in another
	" window with file in another dir. So we are not using this (it might
	" happen that we end up in a wrong server though).
	let files 	= getbufvar(nr, "ListOfFiles")
	let main_file 	= getbufvar(nr, "atp_MainFile")
	if string(files) != "" 
	    call add(file_list, main_file)
	endif
	if string(main_file) != ""
	    call extend(file_list, files)
	endif
    endfor
    call filter(file_list, 'v:val != ""')
    redir end
    return file_list
endfunction
function! atplib#FindAndOpen(file, line, ...)
    let col		= ( a:0 >= 1 && a:1 > 0 ? a:1 : 1 )
    let file		= ( fnamemodify(a:file, ":e") == "tex" ? a:file : fnamemodify(a:file, ":p:r") . ".tex" )
    let file_t		= fnamemodify(file, ":t")
    let server_list	= split(serverlist(), "\n")
    exe "redir! > /tmp/FindAndOpen.log"
    if len(server_list) == 0
	return 1
    endif
    let use_server	= ""
    let use_servers	= []
    for server in server_list
	let file_list=split(remote_expr(server, 'atplib#ServerListOfFiles()'), "\n")
	let cond_1 = (index(file_list, file) != "-1")
	let cond_2 = (index(file_list, file_t) != "-1")
	if cond_1
	    let use_server	= server
	    break
	elseif cond_2
	    call add(use_servers, server)
	endif
    endfor
    " If we could not find file name with full path in server list use the
    " first server where is fnamemodify(file, ":t"). 
    if use_server == ""
	let use_server=get(use_servers, 0, "")
    endif
    if use_server != ""
	call system(v:progname." --servername ".use_server." --remote-wait +".a:line." ".fnameescape(file) . " &")
" 	Test this for file names with spaces
	let bufwinnr 	= remote_expr(use_server, 'bufwinnr("'.file.'")')
	if bufwinnr 	== "-1"
" 	    " The buffer is in a different tab page.
	    let tabpage	= 1
" 	    " Find the correct tabpage:
	    for tabnr in range(1, remote_expr(use_server, 'tabpagenr("$")'))
		let tabbuflist = split(remote_expr(use_server, 'tabpagebuflist("'.tabnr.'")'), "\n")
		let tabbuflist_names = split(remote_expr(use_server, 'map(tabpagebuflist("'.tabnr.'"), "bufname(v:val)")'), "\n")
		if count(tabbuflist_names, file) || count(tabfublist_names, file_t)
		    let tabpage = tabnr
		    break
		endif
	    endfor
	    " Goto to the tabpage:
	    if remote_expr(use_server, 'tabpagenr()') != tabpage
		call remote_send(use_server, '<Esc>:tabnext '.tabpage.'<CR>')
	    endif
	    " Check the bufwinnr once again:
	    let bufwinnr 	= remote_expr(use_server, 'bufwinnr("'.file.'")')
	endif

	" winnr() doesn't work remotely, this is a substitute:
	let remote_file = remote_expr(use_server, 'expand("%:t")')
	if remote_file  != file_t
	    call remote_send(use_server, "<Esc>:".bufwinnr."wincmd w<CR>")
	else

	" Set the ' mark, cursor position and redraw:
	call remote_send(use_server, "<Esc>:normal! 'm `'<CR>:call cursor(".a:line.",".a:col.")<CR>:redraw<CR>")
    endif
    return use_server
endfunction
"}}}1

" Various Comparing Functions:
"{{{1 atplib#CompareNumbers
function! atplib#CompareNumbers(i1, i2)
   return ( str2nr(a:i1) == str2nr(a:i2) ? 0 : ( str2nr(a:i1) > str2nr(a:i2) ? 1 : -1 ) )
endfunction
"}}}1
" {{{1 atplib#CompareCoordinates
" Each list is an argument with two values:
" listA=[ line_nrA, col_nrA] usually given by searchpos() function
" listB=[ line_nrB, col_nrB]
" returns 1 iff A is before B
fun! atplib#CompareCoordinates(listA,listB)
    if a:listA[0] < a:listB[0] || 
	\ a:listA[0] == a:listB[0] && a:listA[1] < a:listB[1] ||
	\ a:listA == [0,0]
	" the meaning of the last is that if the searchpos() has not found the
	" beginning (a:listA) then it should return 1 : the env is not started.
	return 1
    else
	return 0
    endif
endfun
"}}}1
" {{{1 atplib#CompareCoordinates_leq
" Each list is an argument with two values!
" listA=[ line_nrA, col_nrA] usually given by searchpos() function
" listB=[ line_nrB, col_nrB]
" returns 1 iff A is smaller or equal to B
function! atplib#CompareCoordinates_leq(listA,listB)
    if a:listA[0] < a:listB[0] || 
	\ a:listA[0] == a:listB[0] && a:listA[1] <= a:listB[1] ||
	\ a:listA == [0,0]
	" the meaning of the last is that if the searchpos() has not found the
	" beginning (a:listA) then it should return 1 : the env is not started.
	return 1
    else
	return 0
    endif
endfunction
"}}}1
" {{{1 atplib#CompareStarAfter
" This is used by atplib#complete#TabCompletion to put abbreviations of starred environment after not starred version
function! atplib#CompareStarAfter(i1, i2)
    if a:i1 !~ '\*' && a:i2 !~ '\*'
	if a:i1 == a:i2
	    return 0
	elseif a:i1 < a:i2
	    return -1
	else
	    return 1
	endif
    else
	let i1 = substitute(a:i1, '\*', '', 'g')
	let i2 = substitute(a:i2, '\*', '', 'g')
	if i1 == i2
	    if a:i1 =~ '\*' && a:i2 !~ '\*'
		return 1
	    else
		return -1
	    endif
	    return 0
	elseif i1 < i2
	    return -1
	else
	    return 1
	endif
    endif
endfunction
" }}}1

" ReadInputFile function reads finds a file in tex style and returns the list
" of its lines. 
" {{{1 atplib#ReadInputFile
" this function looks for an input file: in the list of buffers, under a path if
" it is given, then in the b:atp_OutDir.
" directory. The last argument if equal to 1, then look also
" under g:texmf.
function! atplib#ReadInputFile(ifile,check_texmf)

    let l:input_file = []

    " read the buffer or read file if the buffer is not listed.
    if buflisted(fnamemodify(a:ifile,":t"))
	let l:input_file=getbufline(fnamemodify(a:ifile,":t"),1,'$')
    " if the ifile is given with a path it should be tried to read from there
    elseif filereadable(a:ifile)
	let l:input_file=readfile(a:ifile)
    " if not then try to read it from b:atp_OutDir
    elseif filereadable(b:atp_OutDir . fnamemodify(a:ifile,":t"))
	let l:input_file=readfile(filereadable(b:atp_OutDir . fnamemodify(a:ifile,":t")))
    " the last chance is to look for it in the g:texmf directory
    elseif a:check_texmf && filereadable(findfile(a:ifile,g:texmf . '**'))
	let l:input_file=readfile(findfile(a:ifile,g:texmf . '**'))
    endif

    return l:input_file
endfunction
"}}}1

" URL query: (by some strange reason this is not working moved to url_query.py)
" function! atplib#URLquery(url) "{{{
" python << EOF
" import urllib2, tempfile, vim
" url  = vim.eval("a:url") 
" print(url)
" temp = tempfile.mkstemp("", "atp_ams_")
" 
" f    = open(temp[1], "w+")
" data = urllib2.urlopen(url)
" f.write(data.read())
" vim.command("return '"+temp[1]+"'")
" EOF
" endfunction "}}}

" This function sets the window options common for toc and bibsearch windows.
"{{{1 atplib#setwindow
" this function sets the options of BibSearch, ToC and Labels windows.
function! atplib#setwindow()
" These options are set in the command line
" +setl\\ buftype=nofile\\ filetype=bibsearch_atp   
" +setl\\ buftype=nofile\\ filetype=toc_atp\\ nowrap
" +setl\\ buftype=nofile\\ filetype=toc_atp\\ syntax=labels_atp
	setlocal nonumber
	setlocal norelativenumber
 	setlocal winfixwidth
	setlocal noswapfile	
	setlocal nobuflisted
	if &filetype == "bibsearch_atp"
" 	    setlocal winwidth=30
	    setlocal nospell
	elseif &filetype == "toc_atp"
" 	    setlocal winwidth=20
	    setlocal nospell
	    setlocal cursorline 
	endif
" 	nnoremap <expr> <buffer> <C-W>l	"keepalt normal l"
" 	nnoremap <buffer> <C-W>h	"keepalt normal h"
endfunction
" }}}1
" {{{1 atplib#count
function! atplib#count(line, keyword,...)
   
    let method = ( a:0 == 0 || a:1 == 0 ) ? 0 : 1

    let line=a:line
    let i=0  
    if method==0
	while stridx(line, a:keyword) != '-1'
	    let line	= strpart(line, stridx(line, a:keyword)+1)
	    let i +=1
	endwhile
    elseif method==1
	let pat = a:keyword.'\zs'
	while line =~ pat
	    let line	= strpart(line, match(line, pat))
	    let i +=1
	endwhile
    endif
    return i
endfunction
" }}}1
" Used to append / at the end of a directory name
" {{{1 atplib#append 	
fun! atplib#append(where, what)
    return substitute(a:where, a:what . '\s*$', '', '') . a:what
endfun
" }}}1
" Used to append extension to a file name (if there is no extension).
" {{{1 atplib#append_ext 
" extension has to be with a dot.
fun! atplib#append_ext(fname, ext)
    return substitute(a:fname, a:ext . '\s*$', '', '') . a:ext
endfun
" }}}1

" List Functions:
" atplib#Extend {{{1
" arguments are the same as for extend(), but it adds only the entries which
" are not present.
function! atplib#Extend(list_a,list_b,...)
    let list_a=deepcopy(a:list_a)
    let list_b=deepcopy(a:list_b)
    let diff=filter(list_b,'count(l:list_a,v:val) == 0')
    if a:0 == 0
	return extend(list_a,diff)
    else
	return extend(list_a,diff, a:1)
    endif
endfunction
" }}}1
" {{{1 atplib#Add
function! atplib#Add(list,what)
    let new=[] 
    for element in a:list
	call add(new,element . a:what)
    endfor
    return new
endfunction
"}}}1
" vim:fdm=marker:ff=unix:noet:ts=8:sw=4:fdc=1
