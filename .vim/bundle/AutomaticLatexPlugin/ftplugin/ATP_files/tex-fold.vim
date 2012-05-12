" Language:	latex, tex
" Author:	Johannes Zellner <johannes [at] zellner [dot] org>
" Modified By:  Marcin Szamotulski <mszamot [at] gmail [dot] com>

if exists("g:atp_folding") && !g:atp_folding
    finish
endif

" [-- local settings --]
setlocal foldexpr=TexFold(v:lnum)

" [-- avoid multiple sourcing --]
if exists("*TexFold")
    setlocal foldmethod=expr
    finish
endif

" [-- ATP options --]
if !exists("g:atp_fold_environments")
    let g:atp_fold_environments = 0
endif

let s:class = atplib#search#DocumentClass(b:atp_MainFile)
fun! TexFoldContextWithDepth(line)
    if s:class =~ '^\(ams\)\=art\(icle\)\=$'
	if a:line =~ '\\section\>'		| return 1
	elseif a:line =~ '\\subsection\>'	| return 2
	elseif a:line =~ '\\subsubsection\>'	| return 3
	elseif a:line =~ '\\paragraph\>'	| return 4
	elseif a:line =~ '\\subparagraph\>'	| return 5
	else					| return 0
	endif
    else
	if a:line =~ '\\part\>'			| return 1
	elseif a:line =~ '\\chapter\>'		| return 2
	elseif a:line =~ '\\section\>'		| return 3
	elseif a:line =~ '\\subsection\>'	| return 4
	elseif a:line =~ '\\subsubsection\>'	| return 5
	elseif a:line =~ '\\paragraph\>'	| return 6
	elseif a:line =~ '\\subparagraph\>'	| return 7
	else					| return 0
	endif
    endif
endfun

fun! TexFoldContextFlat(line)
    if a:line =~ '\\\(part\|chapter\|\(sub\)\+section\|\(sub\)\=paragraph\)\>'
	return 1
    else
	return 0
    endif
endfun

fun! TexFold(lnum)
    " remove comments
    let line = substitute(getline(a:lnum), '\(^%\|\s*[^\\]%\).*$', '', 'g')
    " let level = TexFoldContextFlat(line)
      let level = TexFoldContextWithDepth(line)
    if level
	exe 'return ">'.level.'"'
    elseif line =~ '.*\\begin\>.*' && g:atp_fold_environments
	return 'a1'
    elseif line =~ '.*\\end\>.*' && g:atp_fold_environments
	return 's1'
    else
	return '='
    endif
endfun

" [-- trigger indention --]
setlocal foldmethod=expr

" vim:ts=8
