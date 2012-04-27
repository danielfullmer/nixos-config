" Pathogen, auto-load modules
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
"call pathogen#helptags()

" Colorscheme
colorscheme darkspectrum
"colorscheme darkbone
"colorscheme tango2

" Indent, spaces, tabs
set et
set sts=4
set sw=4

set so=4

" UI options
set encoding=utf8
set mousemodel=popup
set hlsearch
set laststatus=2
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" Other options
set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words

" Key bindings
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

noremap <leader>n :NERDTreeToggle<CR>
noremap <leader>t :TlistToggle<CR>

"Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
"map <leader>sa zg
map <leader>s? z=

" Filetypes
filetype plugin on
filetype indent on
syntax on

" Latexsuite rules
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_CompileRule_pdf = 'pdflatex --shell-escape $*'
"let g:Tex_CompileRule_pdf = 'ps4pdf -v $*'
let g:Tex_ViewRule_pdf = 'evince'
let g:Tex_SmartKeyDot = 0
let g:Tex_SmartKeyQuote = 0

let g:haddock_browser = "chrome"

" Control-Space for omnifunc
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>
