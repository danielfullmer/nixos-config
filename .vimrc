set nocompatible
set shell=/bin/bash

" NeoBundle packages!
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#rc()

" UI
NeoBundle 'CSApprox'
NeoBundle 'Colour-Sampler-Pack'
NeoBundle 'Lokaltog/powerline'
"NeoBundle 'bling/vim-airline'
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim

" For async stuff
NeoBundle 'Shougo/vimproc.vim', {
    \ 'build': {
    \   'windows': 'make -f make_mingw32.mak',
    \   'cygwin': 'make -f make_cygwin.mak',
    \   'mac': 'make -f make_mac.mak',
    \   'unix': 'make -f make_unix.mak',
    \   },
    \ }

" Text/File Navigation
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Lokaltog/vim-easymotion'

" Code Completion/Naviation
"NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'taglist.vim'

" Editing
NeoBundle 'agate/vim-align'
NeoBundle 'coderifous/textobj-word-column.vim'

" GIT
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'mattn/gist-vim'
NeoBundle 'vitaly/vim-gitignore'

" Coding
NeoBundle 'scrooloose/syntastic'
NeoBundle 'editorconfig/editorconfig-vim'

" Python
NeoBundle 'klen/python-mode'
NeoBundle 'alfredodeza/pytest.vim'
NeoBundle 'ivanov/vim-ipython'
NeoBundle 'julienr/vimux-pyutils'
NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'michaeljsmith/vim-indent-object'

" Haskell
NeoBundle 'lukerandall/haskellmode-vim'

" HTML
NeoBundle 'rstacruz/sparkup'
NeoBundle 'lukaszb/vim-web-indent'

" LaTeX
NeoBundle 'AutomaticLaTexPlugin'

" Misc
NeoBundle 'benmills/vimux'
NeoBundle 'christoomey/vim-tmux-navigator'
NeoBundle 'sjl/gundo.vim'

" Filetypes
filetype plugin on
filetype indent on
syntax on

" Default tab spacing
set expandtab
set softtabstop=4
set shiftwidth=4
set shiftround

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
colorscheme darkZ
"colorscheme inkpot
"colorscheme tango2
"colorscheme lucius
"colorscheme moria
"colorscheme xoria256
"colorscheme jellybeans
"colorscheme vividchalk

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

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <C-p> :Unite -start-insert file_rec/async<CR>
nnoremap <space>/ :Unite grep:.<CR>
let g:unite_source_history_yank_enable = 1
nnoremap <space>y :Unite history/yank<CR>
nnoremap <space>s :Unite -quick-match buffer<CR>

" Neocomplete
let g:neocomplete#enable_at_startup = 1

" Python
let g:jedi#auto_vim_configuration = 0
set completeopt="menu"
let g:pymode_doc = 0
let g:pymode_run = 0
let g:pymode_lint = 0
let g:pymode_rope = 0

" Tmux-related bindings
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>

map <leader>vp <Esc>:VimuxPromptCommand<CR>
map <leader>vl <Esc>:VimuxRunLastCommand<CR>
map <leader>vi <Esc>:VimuxInspectRunner<CR>
map <leader>vx <Esc>:VimuxCloseRunner<CR>
vmap <leader>vs "vy :call VimuxRunCommand(@v . "\n", 0)<CR>
nmap <leader>vs vip<leader>vs<CR>

" Others...
let g:haddock_browser = "chrome"
let b:atp_Viewer = "evince"
let g:EasyMotion_leader_key = "<space>"

" NeoBundle says this is required
filetype plugin indent on
