# vim: foldmethod=marker
{ config, pkgs, ... }:
{
  programs.vim.packages = with pkgs.vimPlugins; [
    vim2nix
    vim-nix
    vimproc-vim

    # UI
    Colour-Sampler-Pack
    vim-indent-guides
    vim-highlightedyank
    which-key-nvim

    # Colorscheme
    # Plug 'edkolev/promptline.vim'
    # :PromptlineSnapshot ~/.zshrc.prompt airline
    # Plug 'edkolev/tmuxline.vim'
    # :Tmuxline airline
    vim-airline
    # :TmuxlineSnapshot ~/.tmux.line
    # Plug 'merlinrebrovic/focus.vim'

    # Text/File Navigation
    vim-easymotion
    fzf-vim
    fzfWrapper

    # Code Completion / Navigation
    nvim-compe
    # ultisnips
    # vim-snippets
    nerdtree

    # NVIM-specific stuff
    nvim-treesitter.withAllGrammars
    rainbow-delimiters-nvim
    playground # Treesitter playground
    nvim-lspconfig
    lspsaga-nvim
    completion-nvim
    # telescope.nvim
    # lualine.nvim (replace tmuxline?)

    # Editing
    align
    # Plug 'tpope/vim-abolish'
    vim-surround
    editorconfig-vim

    # GIT
    vim-fugitive
    vim-gitgutter
    webapi-vim
    #vim-gist

    # General Coding
    #ale # TODO: See about language server support
    vim-commentary
    # FastFold
    #vim-polyglot # Language pack

    # Misc
    #Plug 'benmills/vimux'
    neco-vim
    vim-tmux-navigator
    gundo-vim
    vim-ledger
  ];
#    { ft_regex = "^tex\$";
#      names = [
#      "vimtex" # TODO: Too slow
#    ]; }
#    { ft_regex = "^python\$";
#      names = [
#        #"vim-ipython"
#        #Plug 'klen/python-mode'
#        #Plug 'alfredodeza/pytest.vim'
#        #Plug 'julienr/vimux-pyutils'
#    ]; }
#    { ft_regex = "^haskell\$";
#      names = [
#        "neco-ghc"
#        #"haskell-vim"
#        #Plug 'lukerandall/haskellmode-vim'
#    ]; }
#    { ft_regex = "^go\$";
#      names = [
#        #Plug 'jnwhiteh/vim-golang'
#    ]; }
#    { ft_regex = "^html\$";
#      names = [
#        #Plug 'rstacruz/sparkup', {'rtp': 'vim/'}
#        #Plug 'lukaszb/vim-web-indent'
#    ]; }
#    { ft_regex = "^markdown\$";
#      names = [
##      vim-pandoc
##      vim-pandoc-syntax
#    ]; }
#  ];
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

" TODO: vimtex now uses g:vimtex_syntax_conceal
let g:tex_conceal = "admgs"
let g:tex_flavor = "latex"
let g:vimtex_fold_enabled = 1

lua << EOF
require("which-key").setup {

}
EOF


lua << EOF
local nvim_lsp = require('lspconfig')

-- Add python-lsp-server[all] to project (via poetry, etc)
nvim_lsp.pylsp.setup{}
nvim_lsp.tsserver.setup{}
nvim_lsp.nil_ls.setup{}
nvim_lsp.hls.setup{}

require('lspsaga').setup({})
EOF


" Compe
lua << EOF
vim.o.completeopt = "menuone,noselect"
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { ''', ''' ,''', ' ', ''', ''', ''', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = false;
    ultisnips = true;
    luasnip = true;
  };
}
EOF
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
highlight link CompeDocumentation NormalFloat
  '';
}
