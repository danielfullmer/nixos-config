set nocompatible
set shell=/bin/bash

" Vundle packages!
filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()
Bundle 'gmarik/vundle'

" UI
Bundle 'CSApprox'
Bundle 'Colour-Sampler-Pack'
Bundle 'Lokaltog/powerline'
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim

" Text/File Navigation
Bundle 'kien/ctrlp.vim'
Bundle 'Lokaltog/vim-easymotion'

" Code Completion/Naviation
Bundle 'scrooloose/nerdtree'
Bundle 'Valloric/YouCompleteMe'
Bundle 'taglist.vim'

" Editing
Bundle 'agate/vim-align'
Bundle 'coderifous/textobj-word-column.vim'

" GIT
Bundle 'tpope/vim-fugitive'
Bundle 'airblade/vim-gitgutter'
Bundle 'mattn/gist-vim'
Bundle 'vitaly/vim-gitignore'

" Coding
Bundle 'scrooloose/syntastic'
Bundle 'editorconfig/editorconfig-vim'

" Python
Bundle 'alfredodeza/pytest.vim'
Bundle 'ivanov/vim-ipython'
Bundle 'julienr/vimux-pyutils'

" Haskell
Bundle 'lukerandall/haskellmode-vim'

" HTML
Bundle 'rstacruz/sparkup'
Bundle 'lukaszb/vim-web-indent'

" LaTeX
Bundle 'AutomaticLaTexPlugin'

" Misc
Bundle 'benmills/vimux'
Bundle 'sjl/gundo.vim'

" Filetypes
filetype plugin on
filetype indent on
syntax on

" Default tab spacing
set et
set sts=4
set sw=4

" UI options
set encoding=utf8
set relativenumber
set laststatus=2
set scrolloff=1

" Mouse
set mouse=a
set ttymouse=xterm2

" Colorscheme
"set background="dark"
"colorscheme darkbone
"colorscheme darkspectrum
"colorscheme inkpot
"colorscheme tango2
"colorscheme lucius
"colorscheme moria
"colorscheme xoria256
"colorscheme jellybeans
colorscheme vividchalk

" Other options
set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words
set nobackup
set noswapfile

" Key bindings
let mapleader=","

map <left> <Esc>:tabp<cr>
map <right> <Esc>:tabn<cr>
map <down> <Esc>:bn<cr>
map <up> <Esc>:bp<cr>

map <leader>n <Esc>:NERDTreeToggle<CR>
map <leader>l <Esc>:TlistToggle<CR>
map <leader>g <Esc>:GundoToggle<CR>

"Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
"map <leader>sa zg
map <leader>s? z=

" Vimux bindings
map <leader>vp <Esc>:VimuxPromptCommand<CR>
map <leader>vl <Esc>:VimuxRunLastCommand<CR>
map <leader>vi <Esc>:VimuxInspectRunner<CR>
map <leader>vx <Esc>:VimuxCloseRunner<CR>
vmap <leader>vs "vy :call VimuxRunCommand(@v . "\n", 0)<CR>
nmap <leader>vs vip<leader>vs<CR>

" Plugin options
let g:haddock_browser = "chrome"
let b:atp_Viewer = "evince"
let g:EasyMotion_leader_key = "\\"
