# vim: foldmethod=marker
{ pkgs, theme }:

let
  myVimPlugins = pkgs.callPackage ./plugins.nix {};
  shellThemeScript = pkgs.writeScript "shellTheme" (import (../../modules/theme/templates + "/shell.${theme.brightness}.nix") { colors=theme.colors; });

  # Airline theme can't be directly sourced anymore. Needs to be in under <rtp>/autoload/airline/themes/
  airlineThemeBase16 = pkgs.vimUtils.buildVimPlugin {
    name = "airlineThemeBase16";
    # TODO: Should be able to use writeTextDir, but that's broken too: https://github.com/NixOS/nixpkgs/issues/50347
    src = pkgs.writeTextFile {name="airlineTheme"; destination="/autoload/airline/themes/base16_nixos_configured.vim"; text=(import (../../modules/theme/templates + "/airline.${theme.brightness}.nix") { colors=theme.colors; });};
  };
in
{
  vam.knownPlugins = pkgs.vimPlugins // myVimPlugins // { inherit airlineThemeBase16; };
  vam.pluginDictionaries = [
    { names = [
      "vim2nix"
      "vim-nix"
      "vimproc"

      # UI {{{
      "Colour-Sampler-Pack"
      "vim-indent-guides"
      "vim-highlightedyank"
      "airline"
      "airlineThemeBase16" # Custom base16 colors
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
      "easymotion"
      "fzf-vim"
      "fzfWrapper"
      # }}}
      # Code Completion / Navigation {{{
      # neocomplete / deocomplete
      "LanguageClient-neovim"
      "ncm2" # TODO: Figure out language server support
      "nvim-yarp" # ncm2 needs this
      "ncm2-bufword"
      "ncm2-path"
      "ncm2-tmux"
      "neosnippet" # Replace with something ncm-compatible?
      "neosnippet-snippets"
      "The_NERD_tree"
      # }}}
      # Editing {{{
      "align"
      # Plug 'tpope/vim-abolish'
      "surround"
      "editorconfig-vim"
      # }}}
      # GIT {{{
      "fugitive"
      "gitgutter"
      "webapi-vim"
      "gist-vim"
      #" }}}
      #" General Coding {{{
      "ale" # TODO: See about language server support
      "commentary"
      "FastFold"
      "polyglot" # Language pack
      #" }}}
      #" Misc {{{
      #Plug 'benmills/vimux'
      "neco-vim"
      "tmux-navigator"
      "gundo"
      #" }}}
    ]; }
    { ft_regex = "^tex\$";
      names = [
      "vimtex" # TODO: Too slow
    ]; }
    { ft_regex = "^python\$";
      names = [
        "ipython"
        #Plug 'klen/python-mode'
        #Plug 'alfredodeza/pytest.vim'
        #Plug 'julienr/vimux-pyutils'
    ]; }
    { ft_regex = "^haskell\$";
      names = [
        "neco-ghc"
        #"haskell-vim"
        #Plug 'lukerandall/haskellmode-vim'
    ]; }
    { ft_regex = "^go\$";
      names = [
        #Plug 'jnwhiteh/vim-golang'
    ]; }
    { ft_regex = "^html\$";
      names = [
        #Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
        #Plug 'lukaszb/vim-web-indent'
    ]; }
    { ft_regex = "^markdown\$";
      names = [
#      vim-pandoc
#      vim-pandoc-syntax
    ]; }
  ];
  customRC = ''
set nocompatible
set backspace=indent,eol,start
set encoding=utf8
let mapleader=" "
set timeoutlen=500
set wildmenu
set lazyredraw
set incsearch
set inccommand=nosplit

set tags+=~/.vim/systags
set grepprg=grep\ -nH\ $*
set dictionary=${pkgs.miscfiles}/share/web2
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
  execute "silent !/bin/sh ${shellThemeScript}"
endif
source ${pkgs.writeText "vimTheme" (import (../../modules/theme/templates + "/neovim.${theme.brightness}.nix") { colors=theme.colors; })}

" Use the theme from airlineThemeBase16
let g:airline_theme="base16_nixos_configured"
let g:airline_powerline_fonts=1

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

" FZF stuff
nnoremap <C-p> :Files<CR>
nnoremap <space>b :Buffers<CR>
nnoremap <space>t :Tags<CR>

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion. TODO: Remove this?
inoremap <expr> <c-x><c-k> fzf#complete('cat ${pkgs.miscfiles}/share/web2')
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

function! s:fzf_statusline()
  " Override statusline as you like
  highlight fzf1 ctermfg=161 ctermbg=251
  highlight fzf2 ctermfg=23 ctermbg=251
  highlight fzf3 ctermfg=237 ctermbg=251
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction

autocmd! User FzfStatusLine call <SID>fzf_statusline()

let g:EasyMotion_leader_key = "<Leader><Leader>"
nmap s <Plug>(easymotion-s)
nmap S <Plug>(easymotion-s2)

"" ncm2 (neovim-completion-manager-2)
au InsertEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect

autocmd Filetype tex call ncm2#register_source({
        \ 'name' : 'vimtex-cmds',
        \ 'priority': 8, 
        \ 'complete_length': -1,
        \ 'scope': ['tex'],
        \ 'matcher': {'name': 'prefix', 'key': 'word'},
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': g:vimtex#re#ncm2#cmds,
        \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
        \ })
autocmd Filetype tex call ncm2#register_source({
        \ 'name' : 'vimtex-labels',
        \ 'priority': 8, 
        \ 'complete_length': -1,
        \ 'scope': ['tex'],
        \ 'matcher': {'name': 'combine',
        \             'matchers': [
        \               {'name': 'substr', 'key': 'word'},
        \               {'name': 'substr', 'key': 'menu'},
        \             ]},
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': g:vimtex#re#ncm2#labels,
        \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
        \ })
autocmd Filetype tex call ncm2#register_source({
        \ 'name' : 'vimtex-files',
        \ 'priority': 8, 
        \ 'complete_length': -1,
        \ 'scope': ['tex'],
        \ 'matcher': {'name': 'combine',
        \             'matchers': [
        \               {'name': 'abbrfuzzy', 'key': 'word'},
        \               {'name': 'abbrfuzzy', 'key': 'abbr'},
        \             ]},
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': g:vimtex#re#ncm2#files,
        \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
        \ })
autocmd Filetype tex call ncm2#register_source({
        \ 'name' : 'bibtex',
        \ 'priority': 8, 
        \ 'complete_length': -1,
        \ 'scope': ['tex'],
        \ 'matcher': {'name': 'combine',
        \             'matchers': [
        \               {'name': 'prefix', 'key': 'word'},
        \               {'name': 'abbrfuzzy', 'key': 'abbr'},
        \               {'name': 'abbrfuzzy', 'key': 'menu'},
        \             ]},
        \ 'word_pattern': '\w+',
        \ 'complete_pattern': g:vimtex#re#ncm2#bibtex,
        \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
        \ })

" supress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" enable auto complete for `<backspace>`, `<c-w>` keys.
" known issue https://github.com/ncm2/ncm2/issues/7
au TextChangedI * call ncm2#auto_trigger()

" When the <Enter> key is pressed while the popup menu is visible, it only hides
" the menu. Use this mapping to hide the menu and also start a new line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" neosnippet
let g:neosnippet#enable_preview = 1
let g:neosnippet#enable_completed_snippet=1
imap <c-j>     <Plug>(neosnippet_expand_or_jump)
vmap <c-j>     <Plug>(neosnippet_expand_or_jump)
inoremap <silent> <c-u> <c-r>=cm#sources#neosnippet#trigger_or_popup("\<Plug>(neosnippet_expand_or_jump)")<cr>
vmap <c-u>     <Plug>(neosnippet_expand_target)

map <leader>n <Esc>:NERDTreeToggle<CR>

"Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<CR>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

let g:pymode_doc = 0
let g:pymode_run = 0
let g:pymode_lint = 0
let g:pymode_rope = 0

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
let g:vimtex_fold_enabled = 1

" Polyglot bring in latex-box which conflicts with vimtex
let g:polyglot_disabled = ['latex']

let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
nnoremap <silent> <Esc>h :TmuxNavigateLeft<cr>
nnoremap <silent> <Esc>j :TmuxNavigateDown<cr>
nnoremap <silent> <Esc>k :TmuxNavigateUp<cr>
nnoremap <silent> <Esc>l :TmuxNavigateRight<cr>
  '';
}
