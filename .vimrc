" vim: foldmethod=marker
" vim-plug packages! {{{
call plug#begin('~/.vim/bundle')

" For async stuff
Plug 'Shougo/vimproc.vim', {'do': 'make -f make_unix.mak'}
" }}}
" UI {{{
Plug 'Colour-Sampler-Pack'

" Colorscheme
Plug 'chriskempson/base16-vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'bling/vim-airline'
Plug 'edkolev/promptline.vim'
":PromptlineSnapshot ~/.zshrc.prompt airline
Plug 'edkolev/tmuxline.vim'
":Tmuxline airline
":TmuxlineSnapshot ~/.tmux.line

Plug 'merlinrebrovic/focus.vim'

" }}}
" Text/File Navigation {{{
Plug 'Shougo/unite.vim'
Plug 'Lokaltog/vim-easymotion'
" }}}
" Code Completion/Navigation {{{
Plug 'Shougo/neocomplete.vim'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'scrooloose/nerdtree'
" }}}
" Editing {{{
Plug 'agate/vim-align'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
Plug 'editorconfig/editorconfig-vim'
" }}}
" GIT {{{
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim'
" }}}
" General Coding {{{
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-commentary'
" }}}
" Python {{{
Plug 'klen/python-mode'
Plug 'alfredodeza/pytest.vim'
Plug 'ivanov/vim-ipython'
Plug 'julienr/vimux-pyutils'
Plug 'davidhalter/jedi-vim'
" }}}
" Haskell {{{
Plug 'lukerandall/haskellmode-vim'
" }}}
" Go {{{
Plug 'jnwhiteh/vim-golang'
" }}}
" HTML {{{
Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
Plug 'lukaszb/vim-web-indent'
" }}}
" LaTeX {{{
Plug 'lervag/vimtex'
" }}}
" Pandoc {{{
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
" }}}
" Misc {{{
Plug 'benmills/vimux'
Plug 'christoomey/vim-tmux-navigator'
Plug 'sjl/gundo.vim'
" }}}

call plug#end()
" Options {{{
set nocompatible
set shell=/bin/bash
set encoding=utf8
let mapleader=","
set timeoutlen=500
set wildmenu
set lazyredraw
set incsearch

set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=/usr/share/dict/words
set nobackup
set noswapfile

" Filetypes.
filetype plugin indent on

set expandtab
set softtabstop=4
set shiftwidth=4
set shiftround

set background=dark
let base16colorspace=256
let g:base16_shell_path="$HOME/.base16-shell/"
colorscheme base16-tomorrow

let g:airline_powerline_fonts=1

set colorcolumn=+1
let g:indent_guides_auto_colors=1
let g:indent_guides_enable_on_vim_startup=1
"hi IndentGuidesEven ctermbg=18
"hi IndentGuidesOdd ctermbg=0

set number
"set relativenumber
set laststatus=2
set scrolloff=1
set conceallevel=2
set cursorline
set title

set list
set listchars=trail:·,tab:»·,precedes:«,extends:»

set linebreak
set showbreak=»»

" Mouse
set mouse=a
set ttymouse=xterm2

call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <C-p> :Unite -start-insert file_rec/async<CR>
nnoremap <leader>/ :Unite grep:.<CR>
let g:unite_source_history_yank_enable = 1
nnoremap <leader>y :Unite history/yank<CR>
nnoremap <leader>b :Unite -quick-match buffer<CR>
nnoremap <leader>s :Unite neosnippet<CR>

" Using ag as recursive command.
let g:unite_source_rec_async_command =
\ 'ag --follow --nocolor --nogroup -g ""'

"let g:EasyMotion_leader_key = "<space>"
nmap s <Plug>(easymotion-s)
nmap S <Plug>(easymotion-s2)

let g:neocomplete#enable_at_startup = 1
let g:neosnippet#enable_preview = 1
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"

map <leader>n <Esc>:NERDTreeToggle<CR>

"Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

set completeopt="menu"
let g:pymode_doc = 0
let g:pymode_run = 0
let g:pymode_lint = 0
let g:pymode_rope = 0

autocmd FileType python setlocal omnifunc=jedi#completions
let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_select_first = 0
let g:jedi#popup_on_dot = 0
let g:jedi#completions_enable = 0

let g:haddock_browser = "xdg-open"
let g:pandoc_syntax_dont_use_conceal_for_rules = ['atx', 'titleblock']
map <leader>vp <Esc>:VimuxPromptCommand<CR>
map <leader>vl <Esc>:VimuxRunLastCommand<CR>
map <leader>vi <Esc>:VimuxInspectRunner<CR>
map <leader>vx <Esc>:VimuxCloseRunner<CR>
vmap <leader>vs "vy :call VimuxRunCommand(@v . "\n", 0)<CR>
nmap <leader>vs vip<leader>vs<CR>

map <leader>g <Esc>:GundoToggle<CR>

let g:tex_conceal = "admgs"
let g:tex_flavor = "latex"
let g:LatexBox_latexmk_async = 1
let g:LatexBox_latexmk_preview_continuously = 1
let g:LatexBox_quickfix = 2

" Keymap Asetmak {{{
" Change from HJKL to HNIO

nnoremap ; :

" Up/down/left/right
" Always go down/up one line regardless of "set wrap". Is that a sane default?
nnoremap h h|xnoremap h h|onoremap h h|
nnoremap n gj|xnoremap n gj|onoremap n gj|
nnoremap i gk|xnoremap i gk|onoremap i gk|
nnoremap o l|xnoremap o l|onoremap o l|

" Turbo navigation
" Works with counts, see ":help complex-repeat"
nnoremap <silent> H @='5h'<CR>|xnoremap <silent> H @='5h'<CR>|onoremap <silent> H @='5h'<CR>|
nnoremap <silent> N @='5gj'<CR>|xnoremap <silent> N @='5gj'<CR>|onoremap <silent> N @='5gj'<CR>|
nnoremap <silent> I @='5gk'<CR>|xnoremap <silent> I @='5gk'<CR>|onoremap <silent> I @='5gk'<CR>|
nnoremap <silent> O @='5l'<CR>|xnoremap <silent> O @='5l'<CR>|onoremap <silent> O @='5l'<CR>|

" Start new lines / append / insert
nnoremap <C-h> I|
nnoremap <C-n> o|
nnoremap <C-i> O|
nnoremap <C-o> A|

" Make insert/add work also in visual line mode like in visual block mode
nnoremap <space> i
xnoremap <silent> <expr> <space> (mode() =~# "[V]" ? "\<C-V>0o$I" : "I")

" inneR text objects
" e.g. dip (delete inner paragraph) is now drp
onoremap r i

" Search
nnoremap k n|xnoremap k n|onoremap k n|
nnoremap K N|xnoremap K N|onoremap K N|

" Window handling
nnoremap <C-W>h <C-W>h|xnoremap <C-W>h <C-W>h|
nnoremap <C-W>H <C-W>H|xnoremap <C-W>H <C-W>H|
nnoremap <C-W>n <C-W>j|xnoremap <C-W>n <C-W>j|
nnoremap <C-W>N <C-W>J|xnoremap <C-W>N <C-W>J|
nnoremap <C-W>i <C-W>k|xnoremap <C-W>i <C-W>k|
nnoremap <C-W>I <C-W>K|xnoremap <C-W>I <C-W>K|
nnoremap <C-W>o <C-W>l|xnoremap <C-W>o <C-W>l|
nnoremap <C-W>O <C-W>L|xnoremap <C-W>O <C-W>L|

let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-n> :TmuxNavigateDown<cr>
nnoremap <silent> <M-i> :TmuxNavigateUp<cr>
nnoremap <silent> <M-o> :TmuxNavigateRight<cr>
nnoremap <silent> <Esc>h :TmuxNavigateLeft<cr>
nnoremap <silent> <Esc>n :TmuxNavigateDown<cr>
nnoremap <silent> <Esc>i :TmuxNavigateUp<cr>
nnoremap <silent> <Esc>o :TmuxNavigateRight<cr>

" }}}
