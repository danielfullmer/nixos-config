" Author:	Marcin Szamotulski
" Description:	This file contains motion and highlight functions of ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

let s:sourced = ( !exists("s:sourced") ? 0 : 1 )

" CTOC Function:
" {{{1 CTOC
function! CTOC(...)

    if &l:filetype !~ 'tex$'
	return ""
    endif

    let winsavedview = winsaveview()
    try
	if bufloaded(atplib#FullPath(b:atp_MainFile))
	    let file = getbufline(bufnr(atplib#FullPath(b:atp_MainFile)), 0, "$")
	elseif filereadable(atplib#FullPath(b:atp_MainFile))
	    let file = readfile(atplib#FullPath(b:atp_MainFile))
	else
	    let s:document_class = ""
	endif
	for fline in file
	    if fline =~# '^\([^%]\|\\%\)*\\documentclass\>'
		break
	    endif
	endfor
	let s:document_class = matchstr(fline, '\\documentclass\[.*\]{\s*\zs[^}]*\ze\s*}')
    catch /E484:/
	if !exists("s:document_class")
	    let s:document_class = ""
	endif
    endtry
    if s:document_class == "beamer"
	let saved_pos = getpos(".")
	if getline(line(".")) =~ '^\([^%]\|\\%\)*\\end\s*{\s*frame\s*}' 
	    call cursor(line(".")-1, len(getline(line("."))))
	endif
	keepjumps call searchpair('^\([^%]\|\\%\)*\\begin\s*{\s*frame\s*}', '', '^\([^%]\|\\%\)*\\end\s*{\s*frame\s*}', 'cbW', '',
		    \ search('^\([^%]\|\\%\)*\\begin\s*{\s*frame\s*}', 'bnW'))
	let limit 	= search('^\([^%]\|\\%\)*\\end\s*{\s*frame\s*}', 'nW')
	let pos	= [ line("."), col(".") ]
	keepjumps call search('^\([^%]\|\\%\)*\frametitle\>\zs{', 'W', limit)
	if pos != getpos(".")[1:2]
	    let a 	= @a
	    if mode() ==# 'n'
		" We can't use this normal mode command in visual mode.
		keepjumps normal! "ayi}
		let title	= substitute(@a, '\_s\+', ' ', 'g')
		let @a 	= a
	    else
		let title	= matchstr(getline(line(".")), '\\frametitle\s*{\s*\zs[^}]*\ze\(}\|$\)')
		let title	= substitute(title, '\s\+', ' ', 'g')
		let title	= substitute(title, '\s\+$', '', 'g')
		if getline(line(".")) =~ '\\frametitle\s*{[^}]*$'
		    let title 	.= " ".matchstr(getline(line(".")+1), '\s*\zs[^}]*\ze\(}\|$\)')
		endif
	    endif
	    call winrestview(winsavedview)
	    return substitute(strpart(title,0,b:atp_TruncateStatusSection/2), '\_s*$', '','')
	else
	    call cursor(saved_pos[1:2])
	    return ""
	endif
    endif

    let names		= atplib#motion#ctoc()
    let chapter_name	= get(names, 0, '')
    let section_name	= get(names, 1, '')
    let subsection_name	= get(names, 2, '')

    if chapter_name == "" && section_name == "" && subsection_name == ""

	if a:0 == '0'
	    echo "" 
	else
	    return ""
	endif
	
    elseif chapter_name != ""
	if section_name != ""
	    if a:0 != 0
		return substitute(strpart(chapter_name,0,b:atp_TruncateStatusSection/2), '\_s*$', '','') . "/" . substitute(strpart(section_name,0,b:atp_TruncateStatusSection/2), '\_s*$', '','')
	    endif
	else
	    if a:0 != 0
		return substitute(strpart(chapter_name,0,b:atp_TruncateStatusSection), '\_s*$', '','')
	    endif
	endif
    elseif chapter_name == "" && section_name != ""
	if subsection_name != ""
	    if a:0 != 0
		return substitute(strpart(section_name,0,b:atp_TruncateStatusSection/2), '\_s*$', '','') . "/" . substitute(strpart(subsection_name,0,b:atp_TruncateStatusSection/2), '\_s*$', '','')
	    endif
	else
	    if a:0 != 0
		return substitute(strpart(section_name,0,b:atp_TruncateStatusSection), '\_s*$', '','')
	    endif
	endif
    elseif chapter_name == "" && section_name == "" && subsection_name != ""
	if a:0 != 0
	    return substitute(strpart(subsection_name,0,b:atp_TruncateStatusSection), '\_s*$', '','')
	endif
    endif
endfunction "}}}1

" Commands And Maps:
augroup ATP_BufList
    " Add opened files to t:atp_toc_buflist.
    au!
    au BufEnter *.tex call atplib#motion#buflist()
augroup END

" {{{1
if exists(":Tags") != 2
    let b:atp_LatexTags = 1
    command! -buffer -bang Tags						:call atplib#motion#LatexTags(<q-bang>)
else
    let b:atp_LatexTags = 0
    command! -buffer -bang LatexTags					:call atplib#motion#LatexTags(<q-bang>)
endif
command! -nargs=? -complete=custom,atplib#motion#RemoveFromToCComp RemoveFromToC	:call atplib#motion#RemoveFromToC(<q-args>)
map	<buffer> <silent> <Plug>JumptoPreviousEnvironment		:call atplib#motion#JumptoEnvironment(1)<CR>
map	<buffer> <silent> <Plug>JumptoNextEnvironment			:call atplib#motion#JumptoEnvironment(0)<CR>
command! -buffer -count=1 Part		:call atplib#motion#ggGotoSection(<q-count>, 'part')
command! -buffer -count=1 Chap		:call atplib#motion#ggGotoSection(<q-count>, 'chapter')
command! -buffer -count=1 Sec		:call atplib#motion#ggGotoSection(<q-count>, 'section')
command! -buffer -count=1 SSec		:call atplib#motion#ggGotoSection(<q-count>, 'subsection')

command! -buffer -nargs=1 -complete=custom,atplib#motion#CompleteDestinations GotoNamedDest	:call atplib#motion#GotoNamedDestination(<f-args>)
command! -buffer -count=1 SkipCommentForward  	:call atplib#motion#SkipComment('fs', 'n', v:count1)
command! -buffer -count=1 SkipCommentBackward 	:call atplib#motion#SkipComment('bs', 'n', v:count1)
vmap <buffer> <Plug>SkipCommentForward	:call atplib#motion#SkipComment('fs', 'v', v:count1)<CR>
vmap <buffer> <Plug>SkipCommentBackward	:call atplib#motion#SkipComment('bs', 'v', , v:count1, col("."))<CR>

imap <Plug>TexSyntaxMotionForward	<Esc>:call atplib#motion#TexSyntaxMotion(1,1,1)<CR>a
imap <Plug>TexSyntaxMotionBackward	<Esc>:call atplib#motion#TexSyntaxMotion(0,1,1)<CR>a
nmap <Plug>TexSyntaxMotionForward	:call atplib#motion#TexSyntaxMotion(1,1)<CR>
nmap <Plug>TexSyntaxMotionBackward	:call atplib#motion#TexSyntaxMotion(0,1)<CR>

imap <Plug>TexJMotionForward	<Esc><Right>:call atplib#motion#JMotion('')<CR>i
imap <Plug>TexJMotionBackward	<Esc>:call atplib#motion#JMotion('b')<CR>a
nmap <Plug>TexJMotionForward	:call atplib#motion#JMotion('')<CR>
nmap <Plug>TexJMotionBackward	:call atplib#motion#JMotion('b')<CR>

" command! -buffer -nargs=1 -complete=buffer MakeToc	:echo atplib#motion#maketoc(fnamemodify(<f-args>, ":p"))[fnamemodify(<f-args>, ":p")] 
command! -buffer -bang -nargs=? TOC	:call atplib#motion#TOC(<q-bang>)
command! -buffer CTOC			:call CTOC()
command! -buffer -bang Labels		:call atplib#motion#Labels(<q-bang>)
command! -buffer -count=1 -nargs=? -complete=customlist,EnvCompletionWithoutStarEnvs Nenv	:call atplib#motion#GotoEnvironment('sW',<q-count>,<q-args>)  | let v:searchforward=1 
command! -buffer -count=1 -nargs=? -complete=customlist,EnvCompletionWithoutStarEnvs Penv	:call atplib#motion#GotoEnvironment('bsW',<q-count>,<q-args>) | let v:searchforward=0
"TODO: These two commands should also work with sections.
command! -buffer -count=1 -nargs=? -complete=custom,atplib#various#F_compl F	:call atplib#motion#GotoEnvironment('sW',<q-count>,<q-args>)  | let v:searchforward=1
command! -buffer -count=1 -nargs=? -complete=custom,atplib#various#F_compl B	:call atplib#motion#GotoEnvironment('bsW',<q-count>,<q-args>) | let v:searchforward=0

nnoremap <silent> <buffer> <Plug>GotoNextEnvironment		:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousEnvironment	:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'')<CR>

nnoremap <silent> <buffer> <Plug>GotoNextMath			:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'math')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousMath		:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'math')<CR>

nnoremap <silent> <buffer> <Plug>GotoNextInlineMath		:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'inlinemath')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousInlineMath		:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'inlinemath')<CR>

nnoremap <silent> <buffer> <Plug>GotoNextDisplayedMath	 	:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'displayedmath')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousDisplayedMath	:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'displayedmath')<CR>

if &l:cpoptions =~# 'B'
    nnoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s","\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSubSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(subsection\\|section\\|chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(section\\|chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextChapter		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\part\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\part\\*\\=\\>", 'vim', 'n')<CR>
    vnoremap <silent> <Plug>vGotoNextPart		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(part\*\=\>\\|\\end\s*{\s*document\s*}\)', 'W')<Bar>exe "normal! b"<CR>
else
    nnoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s",'\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSubSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextChapter		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\part\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\part\\*\\=\\>', 'vim', 'n')<CR>
    vnoremap <silent> <Plug>vGotoNextPart		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(part\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}\\)', 'W')<Bar>exe "normal! b"<CR>
endif

command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NSSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(subsubsection\|subsection\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(subsection\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NChap		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NPart		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\part\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)

if &l:cpoptions =~# 'B'
    nnoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSubSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(subsection\\|section\\|chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(section\\|chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(chapter\\\\|part\\)\\>", ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(chapter\\\\|part\\)\\>", 'vim')<CR
    vnoremap <silent> <Plug>vGotoPreviousChapter	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\part\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\part\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousPart	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(part\*\=\)\>', 'bW')<CR>
else
    nnoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSubSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(chapter\\\\|part\\)\\>', ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(chapter\\\\|part\\)\\>', 'vim')<CR
    vnoremap <silent> <Plug>vGotoPreviousChapter	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\part\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\part\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousPart	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(part\\*\\=\\)\\>', 'bW')<CR>
endif


if &l:cpoptions =~# 'B'
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(\%(sub\)\{1,2}section\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(subsection\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PChap		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PPart		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\part\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
else
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(\\%(sub\\)\\{1,2}section\\|section\\|chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(subsection\\|section\\|chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(section\\|chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PChap		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PPart		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\part\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
endif

command! -buffer NInput				:call atplib#motion#Input("w") 	| let v:searchforward = 1
command! -buffer PInput 			:call atplib#motion#Input("bw")	| let v:searchforward = 0
command! -buffer -nargs=? -bang -complete=customlist,atplib#motion#GotoFileComplete GotoFile	:call atplib#motion#GotoFile(<q-bang>,<q-args>, 0)
command! -buffer -nargs=? -bang -complete=customlist,atplib#motion#GotoFileComplete Edit 	:call atplib#motion#GotoFile(<q-bang>,<q-args>, 0)
command! -bang -nargs=? -complete=customlist,atplib#motion#GotoLabelCompletion GotoLabel  		:call atplib#motion#GotoLabel(<q-bang>, <q-args>)
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
