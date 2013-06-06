set nocompatible

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
noremap <leader>vp <Esc>:VimuxPromptCommand<CR>
noremap <leader>vl <Esc>:VimuxRunLastCommand<CR>
noremap <leader>vi <Esc>:VimuxInspectRunner<CR>
noremap <leader>vx <Esc>:VimuxCloseRunner<CR>
vmap <leader>vs "vy :call VimuxRunCommand(@v . "\n", 0)<CR>
nmap <leader>vs vip<leader>vs<CR>

" Plugin options
let g:haddock_browser = "chrome"
let b:atp_Viewer = "evince"
let g:EasyMotion_leader_key = "\\"
