" vim: foldmethod=marker
" Options {{{
set nocompatible
set shell=/bin/bash
set encoding=utf8
let mapleader=","

set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words
set nobackup
set noswapfile
" }}}
" NeoBundle packages! {{{
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#rc()

" For async stuff
NeoBundle 'Shougo/vimproc.vim', {
    \ 'build': {
    \   'windows': 'make -f make_mingw32.mak',
    \   'cygwin': 'make -f make_cygwin.mak',
    \   'mac': 'make -f make_mac.mak',
    \   'unix': 'make -f make_unix.mak',
    \   },
    \ }
" }}}
" UI {{{
NeoBundle 'Colour-Sampler-Pack'

"" Colorscheme
NeoBundle 'chriskempson/base16-vim'
set background=dark
let base16colorspace=256
colorscheme base16-eighties

NeoBundle 'nathanaelkane/vim-indent-guides'
let g:indent_guides_auto_colors=0
let g:indent_guides_enable_on_vim_startup=1
hi IndentGuidesEven ctermbg=19
hi IndentGuidesOdd ctermbg=0

NeoBundle 'Lokaltog/powerline'
"NeoBundle 'bling/vim-airline'
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim

NeoBundle 'merlinrebrovic/focus.vim'

set number
set relativenumber
set laststatus=2
set scrolloff=1
set conceallevel=2
set cursorline

set list
set listchars=trail:·,tab:»·,precedes:«,extends:»

set linebreak
set showbreak=»»

" Mouse
set mouse=a
set ttymouse=xterm2

map <left> <Esc>:tabp<cr>
map <right> <Esc>:tabn<cr>
map <down> <Esc>:bn<cr>
map <up> <Esc>:bp<cr>
" }}}
" Text/File Navigation {{{
NeoBundle 'Shougo/unite.vim'
call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <C-p> :Unite -start-insert file_rec/async<CR>
nnoremap <space>/ :Unite grep:.<CR>
let g:unite_source_history_yank_enable = 1
nnoremap <space>y :Unite history/yank<CR>
nnoremap <space>s :Unite -quick-match buffer<CR>

" Using ag as recursive command.
let g:unite_source_rec_async_command =
\ 'ag --follow --nocolor --nogroup -g ""'

NeoBundle 'Lokaltog/vim-easymotion'
let g:EasyMotion_leader_key = "<space>"
" }}}
" Code Completion/Navigation {{{
NeoBundle 'Shougo/neocomplete.vim'
let g:neocomplete#enable_at_startup = 1

NeoBundle 'Shougo/neosnippet.vim'
imap <C-j> <Plug>(neosnippet_expand_or_jump)
smap <C-j> <Plug>(neosnippet_expand_or_jump)
xmap <C-j> <Plug>(neosnippet_expand_or_jump)

NeoBundle 'scrooloose/nerdtree'
map <leader>n <Esc>:NERDTreeToggle<CR>
" }}}
" Editing {{{
NeoBundle 'agate/vim-align'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-surround'
NeoBundle 'coderifous/textobj-word-column.vim'
NeoBundle 'editorconfig/editorconfig-vim'

"Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=
" }}}
" Default tab spacing {{{
set expandtab
set softtabstop=4
set shiftwidth=4
set shiftround
" }}}
" GIT {{{
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'mattn/gist-vim'
" }}}
" General Coding {{{
NeoBundle 'scrooloose/syntastic'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'tpope/vim-commentary'
" }}}
" Python {{{
NeoBundle 'klen/python-mode'
set completeopt="menu"
let g:pymode_doc = 0
let g:pymode_run = 0
let g:pymode_lint = 0
let g:pymode_rope = 0

NeoBundle 'alfredodeza/pytest.vim'
NeoBundle 'ivanov/vim-ipython'
NeoBundle 'julienr/vimux-pyutils'
NeoBundle 'michaeljsmith/vim-indent-object'

NeoBundle 'davidhalter/jedi-vim'
autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_select_first = 0
let g:jedi#popup_on_dot = 0
let g:jedi#completions_enable = 0
" }}}
" Haskell {{{
NeoBundle 'lukerandall/haskellmode-vim'
let g:haddock_browser = "xdg-open"
" }}}
" Go {{{
NeoBundle 'jnwhiteh/vim-golang'
" }}}
" HTML {{{
NeoBundle 'rstacruz/sparkup', {'rtp': 'vim/'}
NeoBundle 'lukaszb/vim-web-indent'
" }}}
" LaTeX {{{
NeoBundle 'LaTeX-Box-Team/LaTeX-Box'
let b:atp_Viewer = "evince"
let g:tex_conceal = "admgs"
" }}}
" Pandoc {{{
NeoBundle 'vim-pandoc/vim-pandoc'
NeoBundle 'vim-pandoc/vim-pandoc-syntax'
" }}}
" Misc {{{
NeoBundle 'benmills/vimux'
map <leader>vp <Esc>:VimuxPromptCommand<CR>
map <leader>vl <Esc>:VimuxRunLastCommand<CR>
map <leader>vi <Esc>:VimuxInspectRunner<CR>
map <leader>vx <Esc>:VimuxCloseRunner<CR>
vmap <leader>vs "vy :call VimuxRunCommand(@v . "\n", 0)<CR>
nmap <leader>vs vip<leader>vs<CR>

NeoBundle 'christoomey/vim-tmux-navigator'
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>

NeoBundle 'sjl/gundo.vim'
map <leader>g <Esc>:GundoToggle<CR>

" Filetypes. NeoBundle says we need to do this at the end
filetype plugin indent on
" }}}
