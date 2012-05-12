" This file is a part of ATP.
" Author: Marcin Szamotulski
" Based On: enumitem v2.2

let g:atp_enumitem_commands=[
	    \ '\setlist{', '\setenumerate{', '\setdescription{',
	    \ '\setitemize{', '\SetEnumerateShortLabel{', '\newlist{', 
	    \ '\AddEnumerateCounter{', '\setdisplayed{' 
	    \ ]
let s:env_options = [ 'label=', 'label*=', 'start=', 'ref=', 'align=', 'font=',
	\ 'topsep=', 'partopsep=', 'parsep=', 'itemsep=', 'leftmargin=',
	\ 'rightmargin=', 'listparindent=', 'labelwidth=', 'labelsep=', 'labelindent=', 'itemindent=',
	\ 'resume=', 'resume*=', 'beginpenalty=', 'midpenalty=', 'endpenalty=',
	\ 'before=', 'before*=', 'after=', 'after*=', 'style=', 'noitemsep', 'nolistsep', 'nosep',
	\ 'fullwidth', 'widest=' ]

let g:atp_enumitem_environment_options={
    \ '\<\%(enumerate\|itemize\|description\)\>' : s:env_options
    \ }
let g:atp_enumitem_command_values={
    \ '\\set\%(list\|enumerate\|description\|itemize\){' : s:env_options
    \ }
