set nocompatible

" Vundle packages!
filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'AutomaticLaTexPlugin'
Bundle 'Colour-Sampler-Pack'
Bundle 'wincent/Command-T'
Bundle 'spolu/dwm.vim'
Bundle 'mattn/gist-vim'
Bundle 'sjl/gundo.vim'
Bundle 'lukerandall/haskellmode-vim'
Bundle 'scrooloose/nerdtree'
Bundle 'alfredodeza/pytest.vim'
Bundle 'rstacruz/sparkup'
Bundle 'scrooloose/syntastic'
Bundle 'taglist.vim'
Bundle 'coderifous/textobj-word-column.vim'
Bundle 'agate/vim-align'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'tpope/vim-fugitive'
Bundle 'airblade/vim-gitgutter'
Bundle 'ivanov/vim-ipython'
Bundle 'benmills/vimux'
Bundle 'Valloric/YouCompleteMe'

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
"set number
set hlsearch
set laststatus=2
set scrolloff=1

" Mouse
set mouse=a
set ttymouse=xterm2

" Colorscheme
set background="dark"
"colorscheme darkbone
"colorscheme darkspectrum
"colorscheme inkpot
"colorscheme tango2
"colorscheme lucius
"colorscheme moria
"colorscheme xoria256
colorscheme jellybeans

" Other options
set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words
set nobackup
set noswapfile

" Key bindings
let mapleader=","

noremap <left> <Esc>:tabp<cr>
noremap <right> <Esc>:tabn<cr>
noremap <down> <Esc>:bn<cr>
noremap <up> <Esc>:bp<cr>

noremap <leader>n <Esc>:NERDTreeToggle<CR>
noremap <leader>l <Esc>:TlistToggle<CR>
noremap <leader>g <Esc>:GundoToggle<CR>

"Pressing ,ss will toggle and untoggle spell checking
noremap <leader>ss :setlocal spell!<CR>
noremap <leader>sn ]s
noremap <leader>sp [s
"noremap <leader>sa zg
noremap <leader>s? z=

" Vimux bindings
let g:VimuxOrientation="h"
noremap <leader>rp <Esc>:VimuxPromptCommand<CR>
noremap <leader>rl <Esc>:VimuxRunLastCommand<CR>
noremap <leader>ri <Esc>:VimuxInspectRunner<CR>
noremap <leader>rx <Esc>:VimuxCloseRunner<CR>
noremap <leader>rs <Esc>:VimuxInterruptRunner<CR>

" Plugin options
let g:haddock_browser = "chrome"
let b:atp_Viewer = "evince"
let g:EasyMotion_leader_key = "\\"
