" Pathogen, auto-load modules
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
"call pathogen#helptags()

" Colorscheme
colorscheme inkpot
"colorscheme darkspectrum
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
set guioptions-=mT

" Other options
set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words

" Key bindings
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

noremap <left> <Esc>:tabp<cr>
noremap <right> <Esc>:tabn<cr>
noremap <down> <Esc>:bn<cr>
noremap <up> <Esc>:bp<cr>

noremap <leader>n <Esc>:NERDTreeToggle<CR>
noremap <leader>l <Esc>:TlistToggle<CR>
noremap <leader>g <Esc>:GundoToggle<CR>

" Execute the tests
nmap <silent><Leader>tf <Esc>:Pytest file<CR>
nmap <silent><Leader>tc <Esc>:Pytest class<CR>
nmap <silent><Leader>tm <Esc>:Pytest method<CR>
" cycle through test errors
nmap <silent><Leader>tn <Esc>:Pytest next<CR>
nmap <silent><Leader>tp <Esc>:Pytest previous<CR>
nmap <silent><Leader>te <Esc>:Pytest error<CR>

nmap <silent><Leader>ts <Esc>:Pytest session<CR>

"Pressing ,ss will toggle and untoggle spell checking
noremap <leader>ss :setlocal spell!<CR>
noremap <leader>sn ]s
noremap <leader>sp [s
"noremap <leader>sa zg
noremap <leader>s? z=

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
