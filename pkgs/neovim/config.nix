# vim: foldmethod=marker
{ pkgs, theme }:

let
  myVimPlugins = pkgs.callPackage ./plugins.nix {};
  shellThemeScript = pkgs.writeScript "shellTheme" (import (../../modules/theme/templates + "/shell.${theme.brightness}.nix") { colors=theme.colors; });
in
{
  packages.myVimPackage = with pkgs.vimPlugins; with myVimPlugins; {
    start = [
      vim2nix
      vim-nix
      vimproc

      # UI {{{
      Colour-Sampler-Pack
      vim-indent-guides
      airline
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
      easymotion
      fzf-vim
      fzfWrapper
      # }}}
      # Code Completion / Navigation {{{
      # neocomplete / deocomplete
      nvim-completion-manager # Get more language-specific completion plugins
      neosnippet
      neosnippet-snippets
      The_NERD_tree
      # }}}
      # Editing {{{
      align
      # Plug 'tpope/vim-abolish'
      surround
      editorconfig-vim
      # }}}
      # GIT {{{
      fugitive
      gitgutter
      webapi-vim
      gist-vim
      #" }}}
      #" General Coding {{{
      ale
      commentary
      FastFold
      polyglot # Language pack
      #" }}}
      #" Python {{{
      # XXX: nvim-completion-manager needs pythonPackages.jedi in nix-shell
      #Plug 'klen/python-mode'
      #Plug 'alfredodeza/pytest.vim'
      ipython
      #Plug 'julienr/vimux-pyutils'
      #" }}}
      #" Haskell {{{
      #Plug 'lukerandall/haskellmode-vim'
      neco-ghc
      #" }}}
      #" Go {{{
      #Plug 'jnwhiteh/vim-golang'
      #" }}}
      #" HTML {{{
      #Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
      #Plug 'lukaszb/vim-web-indent'
      #" }}}
      #" LaTeX {{{
      vimtex # TODO: Too slow
      #" }}}
      #" Pandoc {{{
      vim-pandoc
      vim-pandoc-syntax
      #" }}}
      #" Misc {{{
      #Plug 'benmills/vimux'
      neco-vim
      tmux-navigator
      gundo
      #" }}}
    ];
  };
  customRC = ''
" Load packages early
packloadall

set nocompatible
set backspace=indent,eol,start
set encoding=utf8
let mapleader=" "
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
  execute "silent !/bin/sh ${shellThemeScript}"
endif
source ${pkgs.writeText "vimTheme" (import (../../modules/theme/templates + "/neovim.${theme.brightness}.nix") { colors=theme.colors; })}

let g:airline_theme="base16_nixos_configured"
let g:airline_powerline_fonts=1
source ${pkgs.writeText "airlineTheme" (import (../../modules/theme/templates + "/airline.${theme.brightness}.nix") { colors=theme.colors; })}

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

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

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

"" nvim-completion-manager

" don't give |ins-completion-menu| messages.  For example,
" '-- XXX completion (YYY)', 'match 1 of 2', 'The only match',
set shortmess+=c

" When the <Enter> key is pressed while the popup menu is visible, it only hides
" the menu. Use this mapping to hide the menu and also start a new line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Here is an example for expanding snippet in the popup menu with <Enter> key.
" Suppose you use the <C-U> key for expanding snippet.
imap <expr> <CR>  (pumvisible() ?  "\<c-y>\<Plug>(expand_or_nl)" : "\<CR>")
imap <expr> <Plug>(expand_or_nl) (cm#completed_is_snippet() ? "\<C-U>":"\<CR>")

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
let g:vimtex_fold_enabled = 1

" vimtex + nvim-completion-manager integration
augroup my_cm_setup
  autocmd!
  autocmd User CmSetup call cm#register_source({
        \ 'name' : 'vimtex',
        \ 'priority': 8,
        \ 'scoping': 1,
        \ 'scopes': ['tex'],
        \ 'abbreviation': 'tex',
        \ 'cm_refresh_patterns': g:vimtex#re#ncm,
        \ 'cm_refresh': {'omnifunc': 'vimtex#complete#omnifunc'},
        \ })
augroup END

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
