" Pathogen, auto-load modules
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

set et
set sts=4
set sw=4

" Filetypes
filetype plugin on
filetype indent on
syntax on

" UI options
set encoding=utf8
set number
set hlsearch
set laststatus=2
set scrolloff=4

" Colorscheme
set background="dark"
"colorscheme darkbone
"colorscheme darkspectrum
"colorscheme inkpot
"colorscheme tango2
"colorscheme lucius
"colorscheme moria
colorscheme xoria256

" Other options
set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words

" Plugin options
let g:pep8_map='<leader>8'
let g:neocomplcache_enable_at_startup=1

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

" Vimux bindings
noremap <leader>rp <Esc>:VimuxPromptCommand<CR>
noremap <leader>rl <Esc>:VimuxRunLastCommand<CR>
noremap <leader>ri <Esc>:VimuxInspectRunner<CR>
noremap <leader>rx <Esc>:VimuxCloseRunner<CR>
noremap <leader>rs <Esc>:VimuxInterruptRunner<CR>

let g:haddock_browser = "chrome"
