" Title:	Vim syntax file
" Author:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin

syntax match  atp_FileName /^\s*\D.*$/
syntax match  atp_LineNr /^\s*\d\+/ skipwhite nextgroup=atp_Number,atp_Abstract
syntax match  atp_Number /\t\%(\d\+\.\?\)\+/ms=b+1,me=e contained nextgroup=atp_SectionTitle,atp_SubSectionTitle 

syntax match atp_Abstract /\t\+\s\s\(\S\&\D\).*$/ 

syntax match  atp_Chapter /^\s*\d\+\t\+\d\+\s.*/ contains=atp_LineNr,atp_Number,atp_ChapterTitle
" syntax region atp_ChapterTctle matchgroup=atp_ChapterTitle start=/\d\s\(\S\&\D\)/ms=e-1 end=/$/me=e contained oneline

syntax match  atp_Section /^\s*\d\+\t\+\(\d\+\.\d\+\|\s\{3,}\)\s.\+/ contains=atp_LineNr,atp_Number,atp_SectionTitle 
" syntax region atp_SectionTitle matchgroup=atp_SectionTitle start=/\d\s\t\@<!/ms=e+1,ms=e+1 end=/$/me=e contained oneline

syntax match  atp_SubSection /^\s*\d\+\t\+\(\d\+\.\d\+\.\d\+\|\s\{5,}\)\s.\+/ contains=atp_LineNr,atp_Number,atp_SubSectionTitle 
" syntax region atp_SubSectionTitle matchgroup=atp_SubSectionTitle start=/\d\s\t\@<!/ms=e+1,ms=e+1 end=/$/me=e contained oneline

hi link atp_FileName 	Title
hi link atp_LineNr 	LineNr
hi link atp_Number 	Number
hi link atp_Abstract 	Label
hi link atp_Chapter 	Label
hi link atp_Section 	Label 
hi link atp_SubSection 	Label

" hi link atp_ChapterTitle 	Title
" hi link atp_SectionTitle 	Title 
" hi link atp_SubsectionTitle 	Title
