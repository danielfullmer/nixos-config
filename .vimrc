set nocompatible

" Vundle packages!
filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()
Bundle 'gmarik/vundle'

" UI
Bundle 'CSApprox'
Bundle 'Colour-Sampler-Pack'

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

" Languages
Bundle 'AutomaticLaTexPlugin'
Bundle 'lukerandall/haskellmode-vim'
Bundle 'alfredodeza/pytest.vim'
Bundle 'rstacruz/sparkup'
Bundle 'lukaszb/vim-web-indent'
Bundle 'ivanov/vim-ipython'

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
"set number
set hlsearch
set laststatus=2
set scrolloff=1

" Mouse
set mouse=a
set ttymouse=xterm2

" Colorscheme
set t_Co=256
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
