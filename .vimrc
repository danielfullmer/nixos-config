filetype plugin on
filetype indent on
syntax on

set et
set sts=4
set sw=4
set mousemodel=popup
set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words

" Latexsuite rules
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'pdflatex --shell-escape $*'
"let g:Tex_CompileRule_pdf = 'ps4pdf -v $*'
let g:Tex_ViewRule_pdf = 'evince'
let g:Tex_SmartKeyDot = 0
let g:Tex_SmartKeyQuote = 0

let g:haddock_browser = "firefox"

" Control-Space for omnifunc
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>
