" Author:      Marcin Szamotulski
" Description: This script has functions which have to be called before ATP_files/options.vim 
" Note:	       This file is a part of Automatic Tex Plugin for Vim.
" Language:    tex
" Last Change: Tue Dec 06, 2011 at 13:31:10  +0000

" This file contains set of functions which are needed to set to set the atp
" options and some common tools.

let s:sourced 	= exists("s:sourced") ? 1 : 0

" {{{ Variables
if !exists("g:askfortheoutdir") || g:atp_reload_variables
    let g:askfortheoutdir = 0
endif
if !exists("g:atp_raw_texinputs")
    let g:atp_raw_texinputs = substitute(substitute(substitute(system("kpsewhich -show-path tex"),'!!','','g'),'\/\/\+','\/','g'), ':\|\n', ',', 'g')
"     lockvar g:atp_raw_texinputs
endif

" atp tex and bib inputs directories (kpsewhich)
if !exists("g:atp_texinputs") || g:atp_reload_variables
    let path_list	= split(g:atp_raw_texinputs, ',')
    let idx		= index(path_list, '.')
    if idx != -1
	let dot = remove(path_list, index(path_list,'.')) . ","
    else
	let dot = ""
    endif
    call map(path_list, 'v:val . "**"')

    let g:atp_texinputs	= dot . join(path_list, ',')
endif
" a list where tex looks for bib files
" It must be defined before atplib#common#SetProjectName function.
if !exists("g:atp_raw_bibinputs") || g:atp_reload_variables

    let g:atp_raw_bibinputs=substitute(substitute(substitute(
		\ system("kpsewhich -show-path bib"),
		\ '\/\/\+',	'\/',	'g'),	
		\ '!\|\n',	'',	'g'),
		\ ':',		',' ,	'g')
endif
if !exists("g:atp_bibinputs") || g:atp_reload_variables
    let path_list	= split(g:atp_raw_bibinputs, ',')
    let idx		= index(path_list, '.')
    if idx != -1
	let dot = remove(path_list, index(path_list,'.')) . ","
    else
	let dot = ""
    endif
    call map(path_list, 'v:val . "**"')

    let g:atp_bibinputs	= dot . join(path_list, ',')
endif
" }}}

augroup ATP_SetErrorFile
    au BufEnter 	*.tex 		call atplib#common#SetErrorFile()
    au BufEnter 	$l:errorfile 	setl autoread 
augroup END

" TreeOfFiles
function! TreeOfFiles(main_file,...) "{{{1
    let pattern		= a:0 >= 1 	? a:1 : g:atp_inputfile_pattern
    let flat		= a:0 >= 2	? a:2 : 0	
    let run_nr		= a:0 >= 3	? a:3 : 1 
    let time=reltime()
    if has("python") && &filetype != "plaintex" && ( !exists("g:atp_no_python") || g:atp_no_python == 0 )
	" It was not tested on plaintex files.
	call atplib#search#TreeOfFiles_py(a:main_file)
    else
	call atplib#search#TreeOfFiles_vim(a:main_file, pattern, flat, run_nr)
    endif
    " Notes: vim script avrage is 0.38s, python avrage is 0.28
    return [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ]
endfunction "}}}1

" All Status Line related things:
"{{{ Status Line
function! s:StatusOutDir() "{{{
let status=""
if exists("b:atp_OutDir")
    if b:atp_OutDir != "" 
	let status= status . "Output dir: " . pathshorten(substitute(b:atp_OutDir,"\/\s*$","","")) 
    else
	let status= status . "Please set the Output directory, b:atp_OutDir"
    endif
endif	
    return status
endfunction 
"}}}

" There is a copy of this variable in compiler.vim
function! ATPRunning() "{{{

    if !g:atp_statusNotif
	" Do not put any message if user dosn't want it. 
	return ""
    endif

    if g:atp_Compiler =~ '\<python' 
        " For python compiler
        for var in [ "Latex", "Bibtex", "Python" ] 
	    if !exists("b:atp_".var."PIDs")
		let b:atp_{var}PIDs = []
	    endif
	    call atplib#callback#PIDsRunning("b:atp_".var."PIDs")
	endfor
	if len(b:atp_LatexPIDs) > 0
	    let atp_running= len(b:atp_LatexPIDs) 
	elseif len(b:atp_BibtexPIDs) > 0
	    let atp_running= len(b:atp_BibtexPIDs)
	else
	    return ''
	endif
    else
	" for g:atp_Compiler='bash' 
	let atp_running=b:atp_running

	for cmd in keys(g:CompilerMsg_Dict) 
	    if b:atp_TexCompiler =~ '^\s*' . cmd . '\s*$'
		let Compiler = g:CompilerMsg_Dict[cmd]
		break
	    else
		let Compiler = b:atp_TexCompiler
	    endif
	endfor
	if atp_running >= 2
	    return atp_running." ".Compiler
	elseif atp_running >= 1
	    return Compiler
	else
	    return ""
	endif
    endif

    " For g:atp_Compiler='python'
    if exists("g:atp_callback") && g:atp_callback
	if exists("b:atp_LatexPIDs") && len(b:atp_LatexPIDs)>0  

	    for cmd in keys(g:CompilerMsg_Dict) 
		if b:atp_TexCompiler =~ '^\s*' . cmd . '\s*$'
		    let Compiler = g:CompilerMsg_Dict[cmd]
		    break
		else
		    let Compiler = b:atp_TexCompiler
		endif
	    endfor

	    if exists("b:atp_ProgressBar") && type(b:atp_ProgressBar) == 4 && b:atp_ProgressBar != {}
		let max = max(values(b:atp_ProgressBar))
		let progress_bar="[".max."]".( g:atp_statusOutDir ? " " : "" )
	    else
		let progress_bar=""
	    endif

	    if atp_running >= 2
		return atp_running." ".Compiler." ".progress_bar
	    elseif atp_running >= 1
		return Compiler." ".progress_bar
	    else
		return ""
	    endif
	elseif exists("b:atp_BibtexPIDs") && len(b:atp_BibtexPIDs)>0
	    return b:atp_BibCompiler
	elseif exists("b:atp_MakeindexPIDs") && len(b:atp_MakeindexPIDs)>0
	    return "makeindex"
	endif
    endif
    return ""
endfunction "}}}

" {{{ Syntax and Hilighting
" ToDo:
" syntax 	match 	atp_statustitle 	/.*/ 
" syntax 	match 	atp_statussection 	/.*/ 
" syntax 	match 	atp_statusoutdir 	/.*/ 
" hi 	link 	atp_statustitle 	Number
" hi 	link 	atp_statussection 	Title
" hi 	link 	atp_statusoutdir 	String
" }}}

function! s:SetNotificationColor() "{{{
    " use the value of the variable g:atp_notification_{g:colors_name}_guibg
    " if it doesn't exists use the default value (the same as the value of StatusLine
    " (it handles also the reverse option!)
    let colors_name = exists("g:colors_name") ? g:colors_name : "default"
"     let g:cname	= colors_name
" 	Note: the names of variable uses gui but equally well it could be cterm. As
" 	they work in gui and vim. 
    if has("gui_running")
	let notification_guibg = exists("g:atp_notification_".colors_name."_guibg") ?
		    \ g:atp_notification_{colors_name}_guibg :
		    \ ( synIDattr(synIDtrans(hlID("StatusLine")), "reverse") ?
			\ synIDattr(synIDtrans(hlID("StatusLine")), "fg#") :
			\ synIDattr(synIDtrans(hlID("StatusLine")), "bg#") )
	let notification_guifg = exists("g:atp_notification_".colors_name."_guifg") ?
		    \ g:atp_notification_{colors_name}_guifg :
		    \ ( synIDattr(synIDtrans(hlID("StatusLine")), "reverse") ?
			\ synIDattr(synIDtrans(hlID("StatusLine")), "bg#") :
			\ synIDattr(synIDtrans(hlID("StatusLine")), "fg#") )
	let notification_gui = exists("g:atp_notification_".colors_name."_gui") ?
		    \ g:atp_notification_{colors_name}_gui :
		    \ ( (synIDattr(synIDtrans(hlID("StatusLine")), "bold") ? "bold" : "" ) . 
			\ (synIDattr(synIDtrans(hlID("StatusLine")), "underline") ? ",underline" : "" ) .
			\ (synIDattr(synIDtrans(hlID("StatusLine")), "underculr") ? ",undercurl" : "" ) .
			\ (synIDattr(synIDtrans(hlID("StatusLine")), "italic") ? ",italic" : "" ) )
    else
	let notification_guibg = exists("g:atp_notification_".colors_name."_ctermbg") ?
		    \ g:atp_notification_{colors_name}_ctermbg :
		    \ ( synIDattr(synIDtrans(hlID("StatusLine")), "reverse") ?
			\ synIDattr(synIDtrans(hlID("StatusLine")), "fg#") :
			\ synIDattr(synIDtrans(hlID("StatusLine")), "bg#") )
	let notification_guifg = exists("g:atp_notification_".colors_name."_ctermfg") ?
		    \ g:atp_notification_{colors_name}_ctermfg :
		    \ ( synIDattr(synIDtrans(hlID("StatusLine")), "reverse") ?
			\ synIDattr(synIDtrans(hlID("StatusLine")), "bg#") :
			\ synIDattr(synIDtrans(hlID("StatusLine")), "fg#") )
	let notification_gui = exists("g:atp_notification_".colors_name."_cterm") ?
		    \ g:atp_notification_{colors_name}_cterm :
		    \ ( (synIDattr(synIDtrans(hlID("StatusLine")), "bold") ? "bold" : "" ) . 
			\ (synIDattr(synIDtrans(hlID("StatusLine")), "underline") ? ",underline" : "" ) .
			\ (synIDattr(synIDtrans(hlID("StatusLine")), "underculr") ? ",undercurl" : "" ) .
			\ (synIDattr(synIDtrans(hlID("StatusLine")), "italic") ? ",italic" : "" ) )
    endif

    if has("gui_running")
	let g:notification_gui		= notification_gui
	let g:notification_guibg	= notification_guibg
	let g:notification_guifg	= notification_guifg
    else
	let g:notification_cterm	= notification_gui
	let g:notification_ctermbg	= notification_guibg
	let g:notification_ctermfg	= notification_guifg
    endif
    if has("gui_running")
	let prefix = "gui"
    else
	let prefix = "cterm"
    endif
    let hi_gui	 = ( notification_gui   !=  "" && notification_gui   	!= -1 ? " ".prefix."="   . notification_gui   : "" )
    let hi_guifg = ( notification_guifg !=  "" && notification_guifg 	!= -1 ? " ".prefix."fg=" . notification_guifg : "" )
    let hi_guibg = ( notification_guibg !=  "" && notification_guibg 	!= -1 ? " ".prefix."bg=" . notification_guibg : "" )

    if (notification_gui == -1 || notification_guifg == -1 || notification_guibg == -1)
	return
    endif
    " Highlight command:
    try
    execute "hi User".g:atp_statusNotifHi ." ". hi_gui . hi_guifg . hi_guibg
    catch /E418:/
    endtry

endfunction
"}}}

" The main status function, it is called via autocommand defined in 'options.vim'.
let s:errormsg = 0
" a:command = 1/0: 1 if run by a command, then a:1=bang, a:2=ctoc, 
" if a:command = 0, then a:1=ctoc.
function! ATPStatus(command,...) "{{{

    if expand("%") == "[Command Line]" || &l:filetype == "qf"
	" If one uses q/ or q? this status function should not be used.
	return
    endif

    if a:command >= 1
"     if a:0 >= 1 && a:1 != -1
	" This is run be the command :Status (:ATPStatus)
	if a:0 >= 1 && a:1 == ""
	    let g:status_OutDir = s:StatusOutDir()
	    let g:atp_statusOutDir = 1
	else
	    let g:status_OutDir = ""
	    let g:atp_statusOutDir = 0
	endif
	let ctoc = ( a:0 >= 2 && a:2 ? 1 : 0 )
    else
	" This is run by the autocommand group ATP_Status
	if g:atp_statusOutDir
	    let g:status_OutDir = s:StatusOutDir()
	else
	    let g:status_OutDir = ""
	endif
	let ctoc = ( a:0 >= 1 && a:1 ? 1 : 0 )
    endif
    let status_CTOC	= ( ctoc && &l:filetype =~ '^\(ams\)\=tex' ? '%{CTOC("return")}' : '' )
    if g:atp_statusNotifHi > 9 || g:atp_statusNotifHi < 0
	let g:atp_statusNotifHi = 9
	if !s:errormsg
	    echoerr "Wrong value of g:atp_statusNotifHi, should be 0,1,...,9. Setting it to 9."
	    let s:errormsg = 1
	endif
    endif
    let status_NotifHi	=
		\ ( g:atp_statusNotif && g:atp_statusNotifHi 	? '%#User'.g:atp_statusNotifHi . '#' : '' )
    let status_NotifHiPost =
		\ ( g:atp_statusNotif && g:atp_statusNotifHi 	? '%*' 	: '' )
    let status_Notif	=
		\ ( g:atp_statusNotif 			? '%{ATPRunning()}' 	: '' )
    let status_KeyMap	=
		\ ( has("keymap") && g:atp_babel && exists("b:keymap_name") 	
								\ ? b:keymap_name 	: '' )
    let g:atp_StatusLine= '%<%f '.status_KeyMap.'%(%h%m%r%) '.status_NotifHi.status_Notif.status_NotifHiPost.'%= '.status_CTOC.' %{g:status_OutDir} %-14.16(%l,%c%V%)%P'
    set statusline=%!g:atp_StatusLine
endfunction
try
    command -buffer -bang Status	:call ATPStatus(1,<q-bang>) 
catch /E174:/
    command! -buffer -bang ATPStatus	:call ATPStatus(1,<q-bang>) 
endtry
" }}}
"}}}
" The Script:
" (includes commands, and maps - all the things 
" 		that must be sources for each file
" 		+ sets g:atp_inputfile_pattern variable)
" {{{1
call atplib#common#SetProjectName()

" The pattern g:atp_inputfile_pattern should match till the begining of the file name
" and shouldn't use \zs:\ze. 
if !exists("g:atp_inputfile_pattern") || g:atp_reload_variables
    if &filetype == 'plaintex'
	let g:atp_inputfile_pattern = '^[^%]*\\input\>\s*'
    else
	if atplib#search#SearchPackage("subfiles")
	    let g:atp_inputfile_pattern = '^[^%]*\\\(input\s*{\=\|include\s*{\|subfile\s*{'
	else
	    let g:atp_inputfile_pattern = '^[^%]*\\\(input\s*{\=\|include\s*{'
	endif
	if atplib#search#SearchPackage("biblatex")
	    let g:atp_inputfile_pattern .= '\)'
	else
	    let g:atp_inputfile_pattern .= '\|bibliography\s*{\)'
	endif
    endif
endif


call atplib#common#SetOutDir(0, 1)
if expand("%:e") == "tex"
    " cls and sty files also have filetype 'tex', this prevents from setting the error
    " file for them.
    call atplib#common#SetErrorFile()
endif "}}}1

" Commands:
"{{{1
command! -buffer -bang SetProjectName	:call atplib#common#SetProjectName(<q-bang>, 0)
command! -buffer SetErrorFile		:call atplib#common#SetErrorFile()
command! -buffer SetOutDir		:call atplib#common#SetOutDir(1)
command! -buffer InputFiles 		:call atplib#search#UpdateMainFile() | :call atplib#search#FindInputFiles(atplib#FullPath(b:atp_MainFile)) | echo join([b:atp_MainFile]+b:ListOfFiles, "\n")

" This should set the variables and run atplib#common#SetNotificationColor function
command! -buffer SetNotificationColor :call atplib#common#SetNotificationColor()
augroup ATP_SetStatusLineNotificationColor
    au!
    au VimEnter 		*.tex 	:call s:SetNotificationColor()
    au BufEnter 		*.tex 	:call s:SetNotificationColor()
    au ColorScheme 		* 	:call s:SetNotificationColor()
augroup END
"}}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
