# vim: foldmethod=marker
{ config, pkgs, ... }:
{
  programs.vim.knownPlugins = pkgs.vimPlugins // pkgs.callPackage ./plugins.nix {};
  programs.vim.pluginDictionaries = [
    { names = [
      "vim2nix"
      "vim-nix"
      "vimproc"

      # UI {{{
      "Colour-Sampler-Pack"
      "vim-indent-guides"
      "vim-highlightedyank"
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
      "ncm2-jedi"
      "ncm2-ultisnips"
      "ultisnips"
      "vim-snippets"
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
      #"vim-gist"
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
  programs.vim.configBeforePlugins = ''
    " Polyglot bring in latex-box which conflicts with vimtex
    let g:polyglot_disabled = ['latex']
  '';
  programs.vim.config = ''
set nocompatible
set backspace=indent,eol,start
set encoding=utf8
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

autocmd FileType go set noexpandtab
autocmd FileType go set shiftwidth=8

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

function! s:fzf_statusline()
  " Override statusline as you like
  highlight fzf1 ctermfg=161 ctermbg=251
  highlight fzf2 ctermfg=23 ctermbg=251
  highlight fzf3 ctermfg=237 ctermbg=251
  setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
endfunction

autocmd! User FzfStatusLine call <SID>fzf_statusline()


" supress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=c

" enable auto complete for `<backspace>`, `<c-w>` keys.
" known issue https://github.com/ncm2/ncm2/issues/7
au TextChangedI * call ncm2#auto_trigger()

" When the <Enter> key is pressed while the popup menu is visible, it only hides
" the menu. Use this mapping to hide the menu and also start a new line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")


"" Snippets
"let g:UltiSnipsSnippetDirectories = [ "${./UltiSnips}", "UltiSnips" ]

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

map <leader>n <Esc>:NERDTreeToggle<CR>

let g:pymode_doc = 0
let g:pymode_run = 0
let g:pymode_lint = 0
let g:pymode_rope = 0

let g:haddock_browser = "xdg-open"
let g:pandoc_syntax_dont_use_conceal_for_rules = ['atx', 'titleblock']
# TODO: vimtex now uses g:vimtex_syntax_conceal
let g:tex_conceal = "admgs"
let g:tex_flavor = "latex"
let g:vimtex_fold_enabled = 1
  '';
}
