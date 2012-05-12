" Author: 	Marcin Szamotulski
" Description: 	This file contains help commands and variables (for mappings used by ATP) 
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

" {{{1 Help Math IMAPS
function! atplib#helpfunctions#HelpMathIMaps()

    if exists("g:no_plugin_maps") || exists("g:no_atp_maps")
	echomsg "[ATP:] ATP maps are turned off"
	return ''
    endif

    let g:help_mathimaps = ''
	\."\n MATH IMAPS"
	\."\n <maplocalleader> has value g:atp_imap_leader_1"
	\."\n ".g:atp_imap_leader_1."a \\alpha            ".g:atp_imap_leader_1."b \\beta"
	\."\n ".g:atp_imap_leader_1."g \\gamma            ".g:atp_imap_leader_1."d \\delta"
	\."\n ".g:atp_imap_leader_1."e \\epsilon          ".g:atp_imap_leader_1."ve \\varepsilon"
	\."\n ".g:atp_imap_leader_1."z \\zeta             ".g:atp_imap_leader_1."h \\eta"
	\."\n ".g:atp_imap_leader_1."o \\theta            ".g:atp_imap_leader_1."vo \\vartheta"
	\."\n ".g:atp_imap_leader_1."i \\iota             ".g:atp_imap_leader_1."k \\kappa"
	\."\n ".g:atp_imap_leader_1."l \\lambda           ".g:atp_imap_leader_1."m \\mu"
	\."\n ".g:atp_imap_leader_1."n \\nu               ".g:atp_imap_leader_1."x \\xi"
	\."\n ".g:atp_imap_leader_1."p \\pi               ".g:atp_imap_leader_1."r \\rho"
	\."\n ".g:atp_imap_leader_1."s \\sigma            ".g:atp_imap_leader_1."vs \\varsigma" 
	\."\n ".g:atp_imap_leader_1."t \\tau              ".g:atp_imap_leader_1."u \\upsilon"
	\."\n ".g:atp_imap_leader_1."f \\phi              ".g:atp_imap_leader_1."c \\chi"
	\."\n ".g:atp_imap_leader_1."y \\psi              ".g:atp_imap_leader_1."w \\omega"
	\."\n"
	\."\n ".g:atp_imap_leader_1."G \\Gamma            ".g:atp_imap_leader_1."D \\Delta"
	\."\n ".g:atp_imap_leader_1."Z \\mathrm{Z}        ".g:atp_imap_leader_1."O \\Theta"
	\."\n ".g:atp_imap_leader_1."L \\Lambda           ".g:atp_imap_leader_1."M \\Mu"
	\."\n ".g:atp_imap_leader_1."N \\Nu               ".g:atp_imap_leader_1."P \\Pi"
	\."\n ".g:atp_imap_leader_1."S \\Sigma            ".g:atp_imap_leader_1."U \\Upsilon"
	\."\n ".g:atp_imap_leader_1."F \\Phi              ".g:atp_imap_leader_1."Y \\Psi"
	\."\n ".g:atp_imap_leader_1."W \\Omega"
	\."\n"
	\."\n ".g:atp_imap_leader_1."+ \\bigcup           ".g:atp_imap_leader_1."- \\setminus" 
	\."\n ".g:atp_infty_leader."8 \\infty            ".g:atp_imap_leader_1."& \\wedge"
	\."\n ".                        "^^ ^{}               ".                        "__ _{}"
	\."\n ".g:atp_imap_leader_3."m \\(\\)              ".g:atp_imap_leader_3."M \\[\\]           <maplocalleader> has value g:atp_imap_leader_3" 
    return g:help_mathimaps
endfunction
silent call atplib#helpfunctions#HelpMathIMaps()

" {{{1 Help Environment IMAPS
function! atplib#helpfunctions#HelpEnvIMaps()

    if exists("g:no_plugin_maps") || exists("g:no_atp_maps")
	echomsg "[ATP:] ATP maps are turned off"
	return ''
    endif

    let g:help_envimaps = ''
		\."\n ENVIRONMENT IMAPS" 
		\."\n <maplocalleader> has value g:atp_imap_leader_3"
		\."\n ".(g:atp_imap_begin != "" ? g:atp_imap_leader_3.g:atp_imap_begin." \\begin{}             " : "" ).(g:atp_imap_end != "" ? g:atp_imap_leader_3.g:atp_imap_end." \\end{}" : "")
		\."\n ".(g:atp_imap_theorem != "" ? g:atp_imap_leader_3.g:atp_imap_theorem." theorem              " : "" ).(g:atp_imap_definition != "" ? g:atp_imap_leader_3.g:atp_imap_definition." definition" : "")
		\."\n ".(g:atp_imap_proposition != "" ? g:atp_imap_leader_3.g:atp_imap_proposition." proposition          " : "").(g:atp_imap_lemma != "" ? g:atp_imap_leader_3.g:atp_imap_lemma." lemma" : "")
		\."\n ".(g:atp_imap_remark != "" ? g:atp_imap_leader_3.g:atp_imap_remark." remark               " : "").(g:atp_imap_corollary != "" ? g:atp_imap_leader_3.g:atp_imap_corollary." corollary" : "")
		\."\n ".(g:atp_imap_proof != "" ? g:atp_imap_leader_3.g:atp_imap_proof." proof                " : "").(g:atp_imap_example != "" ? g:atp_imap_leader_3.g:atp_imap_example." example" : "")
		\."\n ".(g:atp_imap_note != "" ? g:atp_imap_leader_3.g:atp_imap_note." note                 " : "")
		\."\n"
		\."\n ".(g:atp_imap_enumerate != "" ? g:atp_imap_leader_3.g:atp_imap_enumerate." enumerate            " : "").(g:atp_imap_itemize != "" ? g:atp_imap_leader_3.g:atp_imap_itemize." itemize" : "")
		\."\n ".(g:atp_imap_item != "" ? g:atp_imap_leader_3.g:atp_imap_item." \\item" : "")
		\."\n"
		\.(g:atp_imap_align != "" ? "\n ".g:atp_imap_leader_3.g:atp_imap_align." align                " : "").(g:atp_imap_equation != "" ? g:atp_imap_leader_3.g:atp_imap_equation." equation" : "")
		\."\n"
		\."\n ".(g:atp_imap_flushleft != "" ? g:atp_imap_leader_3.g:atp_imap_flushleft." flushleft            " : "").(g:atp_imap_flushright != "" ? g:atp_imap_leader_3.g:atp_imap_flushright." flushright" : "")
		\."\n ".(g:atp_imap_center != "" ? g:atp_imap_leader_3.g:atp_imap_center." center" : "")
		\."\n"
		\.(g:atp_imap_tikzpicture != "" ? "\n ".g:atp_imap_leader_3.g:atp_imap_tikzpicture." tikzpicture" : "")
		\."\n"
		\."\n ".(g:atp_imap_frame != "" ? g:atp_imap_leader_3.g:atp_imap_frame." frame                " : "").(g:atp_imap_letter != "" ?  g:atp_imap_leader_3.g:atp_imap_letter." letter" : "" )
    return g:help_envimaps
endfunction

" {{{1 Help VMaps
function! atplib#helpfunctions#HelpVMaps() 

    if exists("g:no_plugin_maps") || exists("g:no_atp_maps")
	echomsg "[ATP:] ATP maps are turned off"
	return ''
    endif

    let l:atp_vmap_text_font_leader 	= ( exists("maplocalleader") && g:atp_vmap_text_font_leader 	== "<LocalLeader>" ? maplocalleader : g:atp_vmap_text_font_leader )
    let l:atp_vmap_environment_leader 	= ( exists("maplocalleader") && g:atp_vmap_environment_leader 	== "<LocalLeader>" ? maplocalleader : g:atp_vmap_environment_leader )
    let l:atp_vmap_bracket_leader 	= ( exists("maplocalleader") && g:atp_vmap_bracket_leader 	== "<LocalLeader>" ? maplocalleader : g:atp_vmap_bracket_leader )
    let l:atp_vmap_big_bracket_leader 	= ( exists("maplocalleader") && g:atp_vmap_big_bracket_leader 	=~ "<LocalLeader>" ? substitute(g:atp_vmap_big_bracket_leader, '<LocalLeader>', maplocalleader, '')  : g:atp_vmap_big_bracket_leader )

    let g:help_vmaps = ''
	    \."\n <maplocalleader> has value g:atp_vmap_text_font_leader"
	    \."\n KEYMAP            TEXT MODE            MATH MODE"
	    \."\n ".l:atp_vmap_text_font_leader."rm               \\textrm{}            \\mathrm{}"
	    \."\n ".l:atp_vmap_text_font_leader."em               \\emph{}              \\mathit{}"
	    \."\n ".l:atp_vmap_text_font_leader."it               \\textit{}            \\mathit{}"
	    \."\n ".l:atp_vmap_text_font_leader."sf               \\textsf{}            \\mathsf{}"
	    \."\n ".l:atp_vmap_text_font_leader."tt               \\texttt{}            \\mathtt{}"
	    \."\n ".l:atp_vmap_text_font_leader."bf               \\textbf{}            \\mathbf{}"
	    \."\n ".l:atp_vmap_text_font_leader."bb               \\textbf{}            \\mathbb{}"
	    \."\n ".l:atp_vmap_text_font_leader."bb               \\textbf{}            \\mathbb{}"
	    \."\n ".l:atp_vmap_text_font_leader."sl               \\textsl{}"
	    \."\n ".l:atp_vmap_text_font_leader."sc               \\textsc{}"
	    \."\n ".l:atp_vmap_text_font_leader."up               \\textup{}"
	    \."\n ".l:atp_vmap_text_font_leader."md               \\textmd{}"
	    \."\n ".l:atp_vmap_text_font_leader."un               \\underline{}         \\underline{}"
	    \."\n ".l:atp_vmap_text_font_leader."ov               \\overline{}          \\overline{}"
	    \."\n ".l:atp_vmap_text_font_leader."no               \\textnormal{}        \\mathnormal{}"
	    \."\n ".l:atp_vmap_text_font_leader."cal                                   \\mathcal{}"
	    \."\n "
	    \."\n MODE INDEPENDENT VMAPS:"
	    \."\n <maplocalleader> has value g:atp_vmap_environment_leader"
	    \."\n ".l:atp_vmap_environment_leader."C		   wrap in center environment"
	    \."\n ".l:atp_vmap_environment_leader."L		   wrap in flushleft environment"
	    \."\n ".l:atp_vmap_environment_leader."R		   wrap in flushright environment"
	    \."\n ".l:atp_vmap_environment_leader."E		   wrap in equation environment"
	    \."\n ".l:atp_vmap_environment_leader."A		   wrap in align environment"
	    \."\n "
	    \."\n <maplocalleader> has value g:atp_vmap_bracket_leader"
	    \."\n ".l:atp_vmap_bracket_leader."(                (:)            ".l:atp_vmap_bracket_leader.")           (:)" 
	    \."\n ".l:atp_vmap_bracket_leader."[                [:]            ".l:atp_vmap_bracket_leader."]           [:]" 
	    \."\n ".l:atp_vmap_bracket_leader."{                {:}            ".l:atp_vmap_bracket_leader."}           {:}" 
	    \."\n ".l:atp_vmap_bracket_leader."\\{              \\{:\\}           ".l:atp_vmap_bracket_leader."\\}         \\{:\\}" 
	    \."\n m                \\(:\\)           M           \\[:\\] "
	    \."\n "
	    \."\n <maplocalleader> has value g:atp_vmap_big_bracket_leader"
	    \."\n ".l:atp_vmap_big_bracket_leader."(          \\left(:\\right)      ".l:atp_vmap_big_bracket_leader.")     \\left(:\\right)" 
	    \."\n ".l:atp_vmap_big_bracket_leader."[          \\left[:\\right]      ".l:atp_vmap_big_bracket_leader."]     \\left[:\\right]" 
	    \."\n ".l:atp_vmap_big_bracket_leader."{          \\left{:\\right}      ".l:atp_vmap_big_bracket_leader."}     \\left{:\\right}" 
	    \."\n ".l:atp_vmap_big_bracket_leader."\\{        \\left\\{:\\right\\}     ".l:atp_vmap_big_bracket_leader."\\}   \\left\\{:\\right\\}" 
	    \."\n "
	    \."\n ".l:atp_vmap_text_font_leader."f                \\usefont{".g:atp_font_encoding."}{}{}{}\\selectfont" 
    return g:help_vmaps 
endfunction
" {{{1 Help IMaps
" function! atplib#helpfunctions#HelpIMaps()
" let tc_imap = maparg("<Tab>  ", 'i') =~# 'atplib#complete#TabCompletion' ? '<Tab>' : 
" 	    \ maparg("<F7>   ", 'i') =~# 'atplib#complete#TabCompletion' ? '<F7>' : ""
" let netc_imap = tc_imap == "<Tab>" ? "<S-Tab>" : tc_imap == "<F7>" ? "<S-F7>" : ""
"     let g:help_imaps = ''
" 	    \."\n <maplocalleader> has value g:atp_vmap_text_font_leader"
" 	    \."\n ".tc_imap."            "."Completion (expert mode)"
" 	    \."\n ".netc_imap."            "."Completion (non-expert mode)"
" endfunction
" silent call atplib#helpfunctions#HelpIMaps()
" command! -buffer HelpIMaps :echo atplib#helpfunctions#HelpIMaps()
" }}}1
function! atplib#helpfunctions#MapSearch(bang,rhs_pattern,...)
    let mode = ( a:0 >= 1 ? a:1 : '' )
    let more = &more
    setl nomore
    redir => maps
	exe "silent ".mode."map"
    redir end
    let &l:more = more
    let list = split(maps, "\n")
    let rhs_list  = ( a:bang == "" ? map(copy(list), 'matchstr(v:val, ''.\s\+\S\+\s\+\zs.*'')') :
		\ map(copy(list), 'matchstr(v:val, ''.\s\+\zs\S\+\s\+.*'')') )
    if a:bang == "!"
	let pure_rhs_list = map(copy(list), 'matchstr(v:val, ''.\s\+\S\+\s\+\zs.*'')')
    else
	let pure_rhs_list = rhs_list
    endif
    if mode == 'i'
	let j=0
	for entry in g:atp_imap_greek_letters
		    \ +g:atp_imap_math_misc
		    \ +g:atp_imap_diacritics
		    \ +g:atp_imap_environments
		    \ +g:atp_imap_math
		    \ +g:atp_imap_fonts 
	    let entry_tab = substitute(entry[4], "\t", '<Tab>', 'g')
	    let entry_tab = substitute(entry_tab, "", '<C-R>', 'g')
	    if index(pure_rhs_list, entry_tab)	== -1 &&
			\ index(pure_rhs_list, "*".entry_tab) == -1 &&
			\ index(pure_rhs_list, "@".entry_tab) == -1 &&
			\ index(pure_rhs_list, "*@".entry_tab) == -1 
		" Debug:
		    let j+=1
		let space = join(map(range(max([12-len(entry[2].entry[3]),1])), "' '"), "")
		call add(list, 'i  '.entry[2].entry[3].space.entry_tab)
		if a:bang == ""
		    call add(rhs_list, entry_tab)
		else
		    call add(rhs_list, 'i  '.entry[2].entry[3].space.entry_tab)
		endif
	    endif
	endfor
    endif
    let i = 0
    let i_list = []
    for rhs in rhs_list
	if rhs =~? a:rhs_pattern
	    call add(i_list, i)
	endif
	let i+=1
    endfor

    let found_maps = []
    for i in i_list
	call add(found_maps, list[i])
    endfor
    if len(found_maps) > 0
	echo join(found_maps, "\n")
    else
	echohl WarningMsg
	echo "No such map"
	echohl None
    endif
endfunction

" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
