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
Plug 'coderifous/textobj-word-column.vim'
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
Plug 'michaeljsmith/vim-indent-object'

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
Plug 'LaTeX-Box-Team/LaTeX-Box'
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
colorscheme base16-eighties

let g:airline_powerline_fonts=1

let g:indent_guides_auto_colors=0
let g:indent_guides_enable_on_vim_startup=1
hi IndentGuidesEven ctermbg=18
hi IndentGuidesOdd ctermbg=0

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

call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <C-p> :Unite -start-insert file_rec/async<CR>
nnoremap <space>/ :Unite grep:.<CR>
let g:unite_source_history_yank_enable = 1
nnoremap <space>y :Unite history/yank<CR>
nnoremap <space>b :Unite -quick-match buffer<CR>
nnoremap <space>s :Unite neosnippet<CR>

" Using ag as recursive command.
let g:unite_source_rec_async_command =
\ 'ag --follow --nocolor --nogroup -g ""'

let g:EasyMotion_leader_key = "<space>"
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

let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <Esc>h :TmuxNavigateLeft<cr>
nnoremap <silent> <Esc>j :TmuxNavigateDown<cr>
nnoremap <silent> <Esc>k :TmuxNavigateUp<cr>
nnoremap <silent> <Esc>l :TmuxNavigateRight<cr>

map <leader>g <Esc>:GundoToggle<CR>

let g:tex_conceal = "admgs"
let g:LatexBox_latexmk_async = 1
let g:LatexBox_latexmk_preview_continuously = 1
let g:LatexBox_quickfix = 2
" }}}
