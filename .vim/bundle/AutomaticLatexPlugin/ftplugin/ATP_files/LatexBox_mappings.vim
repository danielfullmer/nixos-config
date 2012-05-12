" Author:	David Mungerd
" Maintainer:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

let s:loaded = ( !exists("s:loaded") ? 1 : s:loaded+1 )

" begin/end pairs {{{
nmap <buffer> % <Plug>LatexBox_JumpToMatch
nmap <buffer> g% <Plug>LatexBox_BackJumpToMatch
xmap <buffer> % <Plug>LatexBox_JumpToMatch
omap <buffer> <expr> % ( matchstr(getline("."), '^.*\%'.(col(".")+1).'c\\\=\w*\ze') =~ '\\\(begin\\|end\)$' ? ":<C-U>normal V%<CR>" : ":<C-U>normal v%<CR>" )
xmap <buffer> g% <Plug>LatexBox_BackJumpToMatch
vmap <buffer> ie <Plug>LatexBox_SelectCurrentEnvInner
vmap <buffer> iE <Plug>LatexBox_SelectCurrentEnVInner
vmap <buffer> ae <Plug>LatexBox_SelectCurrentEnvOuter
omap <buffer> ie :normal vie<CR>
omap <buffer> ae :normal vae<CR>
vmap <buffer> im <Plug>LatexBox_SelectInlineMathInner
vmap <buffer> am <Plug>LatexBox_SelectInlineMathOuter
omap <buffer> im :normal vim<CR>
omap <buffer> am :normal vam<CR>
