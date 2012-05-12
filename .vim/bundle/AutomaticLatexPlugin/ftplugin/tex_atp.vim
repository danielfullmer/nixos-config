" Title:		Vim filetype plugin file
" Author:		Marcin Szamotulski
" Mailing List: 	atp-vim-list [AT] lists.sourceforge.net
" Do NOT DELETE the line just below, it is used by :UpdateATP (':help atp-:UpdateATP')
" Time Stamp: 28-12-11_17-03
" (but you can edit, if there is a reason for doing this. The format is dd-mm-yy_HH-MM)
" Language:	    tex
" Last Change: Sat Oct 15, 2011 at 15:36:11  +0100
" GetLatestVimScripts: 2945 62 :AutoInstall: tex_atp.vim
" GetLatestVimScripts: 884 1 :AutoInstall: AutoAlign.vim
" Copyright Statement: 
"     This file is a part of Automatic Tex Plugin for Vim.
"
"     Automatic Tex Plugin for Vim is free software: you can redistribute it
"     and/or modify it under the terms of the GNU General Public License as
"     published by the Free Software Foundation, either version 3 of the
"     License, or (at your option) any later version.
" 
"     Automatic Tex Plugin for Vim is distributed in the hope that it will be
"     useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
"     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
"     General Public License for more details.
" 
"     You should have received a copy of the GNU General Public License along
"     with Automatic Tex Plugin for Vim.  If not, see <http://www.gnu.org/licenses/>.
"
"     This licence applies to all files shipped with Automatic Tex Plugin.

" Do not source ATP if g:no_atp is set
if exists("g:no_atp") && g:no_atp == 1
    finish
endif

let b:did_ftplugin	= 1
let g:loaded_AutomaticLatexPlugin = "10.6.4"

if !exists("g:atp_reload_functions")
	let g:atp_reload_functions = 0
endif
if !exists("g:atp_reload_variables")
	let g:atp_reload_variables = 0
endif

if &cpo =~# 'C'
    set cpo-=C
endif
let saved_cpo = &cpo
if &cpo =~ '<'
    setl cpo-=<
endif

	" Source Project Script
	runtime ftplugin/ATP_files/project.vim

	" ATPRC file overwrites project settings
	" (if the user put sth in atprc file, it means that he wants this globbaly) 
	call atplib#ReadATPRC()

	" Functions needed before setting options.
	runtime ftplugin/ATP_files/common.vim

	" Options, global and local variables, autocommands.
	runtime ftplugin/ATP_files/options.vim

	runtime ftplugin/ATP_files/tex-fold.vim

	" Compilation related stuff.
	runtime ftplugin/ATP_files/compiler.vim

" 	let compiler_file = findfile('compiler/tex_atp.vim', &rtp)
" 	if compiler_file
" 		execute 'source ' 	. fnameescape(compiler_file)
" 	endif

	" LatexBox addons (by D.Munger, with some modifications).
	if g:atp_LatexBox

		runtime ftplugin/ATP_files/LatexBox_common.vim
		runtime ftplugin/ATP_files/LatexBox_complete.vim
		runtime ftplugin/ATP_files/LatexBox_motion.vim
		runtime ftplugin/ATP_files/LatexBox_latexmk.vim

	endif

	runtime ftplugin/ATP_files/motion.vim
	runtime ftplugin/ATP_files/search.vim
	runtime ftplugin/ATP_files/various.vim

	" Source maps and menu files.
	runtime ftplugin/ATP_files/mappings.vim

	if g:atp_LatexBox
		" LatexBox mappings.
		runtime ftplugin/ATP_files/LatexBox_mappings.vim
			
	endif

	" Source abbreviations.
	runtime ftplugin/ATP_files/abbreviations.vim

	" The menu.
	runtime ftplugin/ATP_files/menu.vim

	" Read ATPRC once again (to set mapps).
	call atplib#ReadATPRC()

let &cpo=saved_cpo

" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
