# vim: foldmethod=marker
{ pkgs, theme }:
{
  # See http://beyermatthias.de/blog/2015/11/25/how-to-setup-neo-vim-on-nixos/
  vam = {
    knownPlugins = pkgs.vimPlugins // (pkgs.callPackage ./plugins.nix {});

    pluginDictionaries = [
      { name = "vim2nix"; }
      { name = "vimproc"; }

      # UI {{{
      { name = "Colour-Sampler-Pack"; }
      # { name = "vim-indent-guides"; }
      { name = "airline"; }
      #" Colorscheme
      # Plug 'edkolev/promptline.vim'
      # ":PromptlineSnapshot ~/.zshrc.prompt airline
      # Plug 'edkolev/tmuxline.vim'
      # ":Tmuxline airline
      # ":TmuxlineSnapshot ~/.tmux.line
      #
      # Plug 'merlinrebrovic/focus.vim'
      # }}}
      # Text/File Navigation {{{
      { name = "unite"; }
      { name = "easymotion"; }
      # }}}
      # Code Completion/Navigation {{{
      { name = "neocomplete"; }
      # TODO: Consider deocomplete
      { name = "neosnippet"; }
      #Plug 'Shougo/neosnippet-snippets'
      { name = "The_NERD_tree"; }
      # }}}
      # Editing {{{
      { name = "align"; }
      # Plug 'tpope/vim-abolish'
      { name = "surround"; }
      { name = "editorconfig-vim"; }
      # }}}
      # GIT {{{
      { name = "fugitive"; }
      { name = "gitgutter"; }
      { name = "webapi-vim"; }
      { name = "gist-vim"; }
      #" }}}
      #" General Coding {{{
      { name = "syntastic"; }
      { name = "commentary"; }
      #" }}}
      #" Python {{{
      #Plug 'klen/python-mode'
      #Plug 'alfredodeza/pytest.vim'
      { name = "ipython"; }
      #Plug 'julienr/vimux-pyutils'
      #Plug 'davidhalter/jedi-vim'
      # TODO: Consider deoplete-jedi
      #" }}}
      #" Haskell {{{
      #Plug 'lukerandall/haskellmode-vim'
      #" }}}
      #" Go {{{
      #Plug 'jnwhiteh/vim-golang'
      #" }}}
      #" HTML {{{
      #Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
      #Plug 'lukaszb/vim-web-indent'
      #" }}}
      #" LaTeX {{{
      #Plug 'lervag/vimtex'
      { name = "vimtex"; }
      #" }}}
      #" Pandoc {{{
      #Plug 'vim-pandoc/vim-pandoc'
      #Plug 'vim-pandoc/vim-pandoc-syntax'
      { name = "vim-pandoc"; }
      { name = "vim-pandoc-syntax"; }
      #" }}}
      #" Misc {{{
      #Plug 'benmills/vimux'
      #Plug 'christoomey/vim-tmux-navigator'
      { name = "tmux-navigator"; }
      #Plug 'sjl/gundo.vim'
      { name = "gundo"; }
      #" }}}
    ];
  };
  customRC = ''
" Options {{{
set nocompatible
set backspace=indent,eol,start
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

set background=${theme.brightness}
let base16colorspace=256
if !has('gui_running')
  execute "silent !/bin/sh ${import ../shell/theme.script.nix { inherit pkgs theme; }}"
endif
source ${pkgs.writeText "vimTheme" (import (./. + "/theme.${theme.brightness}.nix") { colors=theme.colors; })}

let g:airline_theme="base16_nixos_configured"
let g:airline_powerline_fonts=1
source ${pkgs.writeText "airlineTheme" (import (./airline + "/theme.${theme.brightness}.nix") { colors=theme.colors; })}

set colorcolumn=+1
let g:indent_guides_auto_colors=1
let g:indent_guides_enable_on_vim_startup=1
hi IndentGuidesEven ctermbg=18
hi IndentGuidesOdd ctermbg=0

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
if !has('nvim')
  set ttymouse=xterm2
endif

" See http://sunaku.github.io/tmux-yank-osc52.html
" copy the current text selection to the system clipboard
if has('gui_running')
  noremap <Leader>y "+y
else
  " copy to attached terminal using the yank(1) script:
  " https://github.com/sunaku/home/blob/master/bin/yank
  noremap <silent> <Leader>y y:call system('yank', @0)<Return>
endif

call unite#filters#matcher_default#use(['matcher_fuzzy'])
nnoremap <C-p> :Unite -start-insert file_rec/async<CR>
nnoremap <space>/ :Unite grep:.<CR>
let g:unite_source_history_yank_enable = 1
nnoremap <space>y :Unite history/yank<CR>
nnoremap <space>b :Unite -quick-match buffer<CR>
nnoremap <space>s :Unite neosnippet<CR>

" Using ag as recursive command.
let g:unite_source_rec_async_command =
\ '${pkgs.ag}/bin/ag --follow --nocolor --nogroup -g ""'

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

map <leader>g <Esc>:GundoToggle<CR>

let g:tex_conceal = "admgs"
let g:tex_flavor = "latex"

let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <Esc>h :TmuxNavigateLeft<cr>
nnoremap <silent> <Esc>j :TmuxNavigateDown<cr>
nnoremap <silent> <Esc>k :TmuxNavigateUp<cr>
nnoremap <silent> <Esc>l :TmuxNavigateRight<cr>

" }}}
  '';
}
