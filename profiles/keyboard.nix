# vim: foldmethod=marker

# The goal here is to have one single file where all custom keybinds are set across all programs.
{ config, pkgs, ... }:

{
  # Keyboard firmware {{{
  hardware.dactyl.keymap = ''
    enum layers {
      _NORM,
      _QWERTY,
      _BLUE,
      _ARWS,

      _GREEKL,
      _GREEKU,

      _EMPTY
    };

    // See quantum/quantum_keycodes.h in qmk_firmware source
    const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /* 0: Norman layout - Minimize use of center columns.
    * Swap p and j. Better for ortholinear */
    [_NORM] = KEYMAP(
    KC_EQL,     KC_1,    KC_2,    KC_3,    KC_4,    KC_5, XXXXXXX,          XXXXXXX,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0, KC_MINS, \
    KC_GRV,     KC_Q,    KC_W,    KC_D,    KC_F,    KC_K, XXXXXXX,          XXXXXXX,    KC_P,    KC_U,    KC_R,    KC_L, KC_SCLN, KC_BSLS, \
    KC_TAB,     KC_A,    KC_S,    KC_E,    KC_T,    KC_G,                               KC_Y,    KC_N,    KC_I,    KC_O,    KC_H, KC_QUOT, \
    KC_LSFT,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B, XXXXXXX,          XXXXXXX,    KC_J,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, KC_RSFT, \
    KC_LGUI,   GREEK, XXXXXXX, XXXXXXX, DF(_QWERTY),                                           KC_SPC, XXXXXXX, XXXXXXX, KC_RALT, KC_RCTL, \
                                                  KC_DEL, KC_HOME,          KC_PGUP, KC_RCTL,                                              \
                                                           KC_END,          KC_PGDN,                                                       \
                      KC_BSPC, LCTL_T(KC_ESC), LM(_ARWS,MOD_LGUI),          LM(_ARWS,MOD_LALT), KC_ENT, LT(_BLUE,KC_SPC)                   \
    ),

    /* 1: Qwerty layout - For compatibilty */
    [_QWERTY] = KEYMAP(
    _______, _______, _______, _______, _______, _______, _______,          _______,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0, _______, \
    _______,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T, _______,          _______,    KC_Y,    KC_U,    KC_I,    KC_O,    KC_P, _______, \
    _______,    KC_A,    KC_S,    KC_D,    KC_F,    KC_G,                               KC_H,    KC_J,    KC_K,    KC_L, KC_SCLN, _______, \
    _______,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B, _______,          _______,    KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, _______, \
    _______, _______, _______, _______,DF(_NORM),                                             _______, _______, _______, _______, _______, \
                                                 _______, _______,          _______, _______,                                              \
                                                          _______,          _______,                                                       \
                                        _______, _______, _______,          _______, _______, _______                                      \
    ),

    /* 2: Blueshift */
    [_BLUE] = KEYMAP(
      F(0),    KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5, _______,          _______,   KC_F6,   KC_F7,   KC_F8,   KC_F9,  KC_F10, _______, \
    _______, XXXXXXX, XXXXXXX, KC_CIRC, KC_PLUS, XXXXXXX, _______,          _______, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, _______, \
    _______, KC_TILD, XXXXXXX, KC_UNDS, KC_MINS, XXXXXXX,                            KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT, XXXXXXX, _______, \
    _______, XXXXXXX, KC_LPRN, KC_LBRC, KC_LCBR, XXXXXXX, _______,          _______, XXXXXXX, KC_RCBR, KC_RBRC, KC_RPRN, XXXXXXX, _______, \
    _______, _______, _______, _______, _______,                                              _______, _______, _______, _______, _______, \
                                                 _______, _______,          _______, _______,                                              \
                                                          _______,          _______,                                                       \
                                        _______, _______, _______,          _______, _______, _______                                      \
    ),

    /* 3: Arrows */
    [_ARWS] = KEYMAP(
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______,                            KC_LEFT, KC_DOWN,   KC_UP, KC_RGHT, _______, _______, \
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______,                                              _______, _______, _______, _______, _______, \
                                                 _______, _______,          _______, _______,                                              \
                                                          _______,          _______,                                                       \
                                        _______, _______, _______,          _______, _______, _______                                      \
    ),

    [_GREEKL] = KEYMAP(
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, XXXXXXX,X(FSIGM),X(LDELT), X(LPHI),X(LKAPP), _______,          _______,  X(LPI),X(LTHET), X(LRHO),X(LLAMB), _______, _______, \
    _______,X(LALPH),X(LSIGM),X(LEPSI), X(LTAU),X(LGAMM),                           X(LUPSI),  X(LNU),X(LIOTA),X(LOMIC), X(LETA), _______, \
    _______,X(LZETA), X(LCHI), X(LPSI),X(LOMEG),X(LBETA), _______,          _______,  X(LXI),  X(LMU), _______, _______, _______, _______, \
    _______, _______, _______, _______, _______,                                              _______, _______, _______, _______, _______, \
                                                 _______, _______,          _______, _______,                                              \
                                                          _______,          _______,                                                       \
                                        _______, _______, _______,          _______, _______, _______                                      \
    ),

    [_GREEKU] = KEYMAP(
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, XXXXXXX, XXXXXXX,X(UDELT), X(UPHI),X(UKAPP), _______,          _______,  X(UPI),X(UTHET), X(URHO),X(ULAMB), _______, _______, \
    _______,X(UALPH),X(USIGM),X(UEPSI), X(UTAU),X(UGAMM),                           X(UUPSI),  X(UNU),X(UIOTA),X(UOMIC), X(UETA), _______, \
    _______,X(UZETA), X(UCHI), X(UPSI),X(UOMEG),X(UBETA), _______,          _______,  X(UXI),  X(UMU), _______, _______, _______, _______, \
    _______, _______, _______, _______, _______,                                              _______, _______, _______, _______, _______, \
                                                 _______, _______,          _______, _______,                                              \
                                                          _______,          _______,                                                       \
                                        _______, _______, _______,          _______, _______, _______                                      \
    ),

    [_EMPTY] = KEYMAP(
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______,                            _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______, _______, _______,          _______, _______, _______, _______, _______, _______, _______, \
    _______, _______, _______, _______, _______,                                              _______, _______, _______, _______, _______, \
                                                 _______, _______,          _______, _______,                                              \
                                                          _______,          _______,                                                       \
                                        _______, _______, _______,          _______, _______, _______                                      \
    ),

    };
  '';
  # }}}

  # fzf shell keybinds:
  # CTRL-R: search history
  # CTRL-T: search files
  # ALT-C: change directory
  programs.bash.interactiveShellInit = ''
    source ${pkgs.fzf}/share/fzf/completion.bash # Activated with **<TAB>
    source ${pkgs.fzf}/share/fzf/key-bindings.bash # CTRL-R, CTRL-T, and ALT-C
  '';
  programs.zsh.interactiveShellInit = ''
    source ${pkgs.fzf}/share/fzf/completion.zsh # Activated with **<TAB>
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh # CTRL-R, CTRL-T, and ALT-C
  '';

  # tmux {{{
  programs.tmux.config = ''
    set-option -g prefix C-a
    bind a send-prefix

    bind -n M-1 select-window -t :1
    bind -n M-2 select-window -t :2
    bind -n M-3 select-window -t :3
    bind -n M-4 select-window -t :4
    bind -n M-5 select-window -t :5
    bind -n M-6 select-window -t :6
    bind -n M-7 select-window -t :7
    bind -n M-8 select-window -t :8
    bind -n M-9 select-window -t :9

    bind s split-window -v
    bind -n M-s split-window -v
    bind v split-window -h
    bind -n M-v split-window -h

    # Smart pane switching with awareness of Vim splits.
    # See: https://github.com/christoomey/vim-tmux-navigator
    is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|\.?n?vim?x?)(-wrapped)?(diff)?$'"

    # M-(h,j,k,l)
    bind-key -n M-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
    bind-key -n M-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
    bind-key -n M-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
    bind-key -n M-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
    #bind-key -n M-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
    bind-key -T copy-mode-vi M-h select-pane -L
    bind-key -T copy-mode-vi M-j select-pane -D
    bind-key -T copy-mode-vi M-k select-pane -U
    bind-key -T copy-mode-vi M-l select-pane -R
    #bind-key -T copy-mode-vi M-\ select-pane -l

    # M-(Up,Down,Left,Right)
    bind-key M-Left if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
    bind-key M-Down if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
    bind-key M-Up if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
    bind-key M-Right if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
    bind-key -T copy-mode-vi M-Left select-pane -L
    bind-key -T copy-mode-vi M-Down select-pane -D
    bind-key -T copy-mode-vi M-Up select-pane -U
    bind-key -T copy-mode-vi M-Right select-pane -R

    bind -rn M-H resize-pane -L 3
    bind -rn M-J resize-pane -R 3
    bind -rn M-K resize-pane -D 3
    bind -rn M-L resize-pane -U 3


    ## Copy / Paste
    # See http://sunaku.github.io/tmux-yank-osc52.html

    # transfer copied text to attached terminal with yank:
    # https://github.com/sunaku/home/blob/master/bin/yank
    bind-key -Tcopy-mode-vi y send -X copy-pipe 'yank > #{pane_tty}'

    # transfer copied text to attached terminal with yank:
    # https://github.com/sunaku/home/blob/master/bin/yank
    bind-key -n M-y run-shell 'tmux save-buffer - | yank > #{pane_tty}'

    # transfer previously copied text (chosen from a menu) to attached terminal:
    # https://github.com/sunaku/home/blob/master/bin/yank
    bind-key -n M-Y choose-buffer 'run-shell "tmux save-buffer -b \"%%\" - | yank > #{pane_tty}"'
  '';
  # }}}

  # i3 {{{
  services.xserver.windowManager.i3.config = ''
    set $mod Mod4

    # Use Mouse+$mod to drag floating windows to their wanted position
    floating_modifier $mod

    # start a terminal
    bindsym $mod+Return exec ${pkgs.termite}/bin/termite

    # kill focused window
    bindsym $mod+Shift+q kill

    bindsym $mod+p exec --no-startup-id ${pkgs.termite}/bin/termite -t 'fzf-menu' -e 'i3-dmenu-desktop --dmenu=fzf'
    for_window [title="fzf-menu"] floating enable

    bindsym $mod+Shift+p exec passmenu -fn "${config.theme.fontName}-${toString config.theme.titleFontSize}"
    bindsym $mod+m exec astroid

    # For reference, a quick way to view this file!
    bindsym $mod+Shift+slash exec --no-startup-id ${pkgs.termite}/bin/termite -t 'help-screen' -e 'vim ${./keyboard.nix}'
    for_window [title="help-screen"] fullscreen enable

    # Use pactl to adjust volume in PulseAudio.
    set $refresh_i3status killall -SIGUSR1 i3status
    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
    bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

    # Media control
    bindsym XF86AudioPlay exec --no-startup-id playerctl play-pause && $refresh_i3status
    bindsym XF86AudioPause exec --no-startup-id playerctl pause && $refresh_i3status
    bindsym XF86AudioStop exec --no-startup-id playerctl stop && $refresh_i3status
    bindsym XF86AudioNext exec --no-startup-id playerctl next && $refresh_i3status
    bindsym XF86AudioPrev exec --no-startup-id playerctl previous && $refresh_i3status

    # Lock screen
    bindsym $mod+Control+l exec ${pkgs.i3lock-pixeled}/bin/i3lock-pixeled

    bindsym XF86MonBrightnessUp   exec light -T 1.3
    bindsym XF86MonBrightnessDown exec light -T 0.77

    # change focus
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    # alternatively, you can use the cursor keys:
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # move focused window
    bindsym $mod+Shift+h move left
    bindsym $mod+Shift+j move down
    bindsym $mod+Shift+k move up
    bindsym $mod+Shift+l move right

    # alternatively, you can use the cursor keys:
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    # split in horizontal/vertical orientation.
    # i3 has the opposite definition as tmux, but I reverse it here to make consistent.
    bindsym $mod+s split v
    bindsym $mod+v split h

    # enter fullscreen mode for the focused container
    bindsym $mod+f fullscreen toggle

    # change container layout (stacked, tabbed, toggle split)
    bindsym $mod+z layout stacking
    bindsym $mod+x layout tabbed
    bindsym $mod+c layout toggle split

    # toggle tiling / floating
    bindsym $mod+Shift+space floating toggle

    # change focus between tiling / floating windows
    bindsym $mod+space focus mode_toggle

    # focus the parent container
    bindsym $mod+u focus parent

    # focus the child container
    bindsym $mod+d focus child

    # switch to workspace
    bindsym $mod+1 workspace $ws1
    bindsym $mod+2 workspace $ws2
    bindsym $mod+3 workspace $ws3
    bindsym $mod+4 workspace $ws4
    bindsym $mod+5 workspace $ws5
    bindsym $mod+6 workspace $ws6
    bindsym $mod+7 workspace $ws7
    bindsym $mod+8 workspace $ws8
    bindsym $mod+9 workspace $ws9
    bindsym $mod+0 workspace $ws10

    # move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace $ws1
    bindsym $mod+Shift+2 move container to workspace $ws2
    bindsym $mod+Shift+3 move container to workspace $ws3
    bindsym $mod+Shift+4 move container to workspace $ws4
    bindsym $mod+Shift+5 move container to workspace $ws5
    bindsym $mod+Shift+6 move container to workspace $ws6
    bindsym $mod+Shift+7 move container to workspace $ws7
    bindsym $mod+Shift+8 move container to workspace $ws8
    bindsym $mod+Shift+9 move container to workspace $ws9
    bindsym $mod+Shift+0 move container to workspace $ws10

    # reload the configuration file
    bindsym $mod+Shift+c reload
    # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
    bindsym $mod+Shift+r restart
    # exit i3 (logs you out of your X session)
    bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"

    # resize window (you can also use the mouse for that)
    mode "resize" {
            # These bindings trigger as soon as you enter the resize mode

            # Pressing left will shrink the window’s width.
            # Pressing right will grow the window’s width.
            # Pressing up will shrink the window’s height.
            # Pressing down will grow the window’s height.
            bindsym h resize shrink width 10 px or 10 ppt
            bindsym j resize grow height 10 px or 10 ppt
            bindsym k resize shrink height 10 px or 10 ppt
            bindsym l resize grow width 10 px or 10 ppt

            # same bindings, but for the arrow keys
            bindsym Left resize shrink width 10 px or 10 ppt
            bindsym Down resize grow height 10 px or 10 ppt
            bindsym Up resize shrink height 10 px or 10 ppt
            bindsym Right resize grow width 10 px or 10 ppt

            # back to normal: Enter or Escape
            bindsym Return mode "default"
            bindsym Escape mode "default"
    }

    bindsym $mod+r mode "resize"
  '';
  # }}}

  # vim {{{
  programs.vim.config = ''
    let mapleader=" "

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
    nnoremap <C-t> :Files<CR>
    nnoremap <C-p> :Rg<CR>
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

    let g:EasyMotion_leader_key = "<Leader><Leader>"
    nmap s <Plug>(easymotion-s)
    nmap S <Plug>(easymotion-s2)

    " ncm2 (neovim-completion-manager-2)
    au InsertEnter * call ncm2#enable_for_buffer()
    set completeopt=noinsert,menuone,noselect

    " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<tab>"
    let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

    "Pressing " "ss will toggle and untoggle spell checking
    map <leader>ss :setlocal spell!<CR>
    map <leader>sn ]s
    map <leader>sp [s
    map <leader>sa zg
    map <leader>s? z=

    map <leader>vp <Esc>:VimuxPromptCommand<CR>
    map <leader>vl <Esc>:VimuxRunLastCommand<CR>
    map <leader>vi <Esc>:VimuxInspectRunner<CR>
    map <leader>vx <Esc>:VimuxCloseRunner<CR>
    vmap <leader>vs "vy :call VimuxRunCommand(@v . "\n", 0)<CR>
    nmap <leader>vs vip<leader>vs<CR>

    map <leader>g <Esc>:GundoToggle<CR>

    let g:tmux_navigator_no_mappings = 1
    nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
    nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
    nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
    nnoremap <silent> <M-l> :TmuxNavigateRight<cr>
    nnoremap <silent> <M-Left> :TmuxNavigateLeft<cr>
    nnoremap <silent> <M-Down> :TmuxNavigateDown<cr>
    nnoremap <silent> <M-Up> :TmuxNavigateUp<cr>
    nnoremap <silent> <M-Right> :TmuxNavigateRight<cr>
    nnoremap <silent> <Esc>h :TmuxNavigateLeft<cr>
    nnoremap <silent> <Esc>j :TmuxNavigateDown<cr>
    nnoremap <silent> <Esc>k :TmuxNavigateUp<cr>
    nnoremap <silent> <Esc>l :TmuxNavigateRight<cr>

    lua << EOF
    local nvim_lsp = require('lspconfig')
      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        --Enable completion triggered by <c-x><c-o>
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        local opts = { noremap=true, silent=true }

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

      end

      -- Use a loop to conveniently call 'setup' on multiple servers and
      -- map buffer local keybindings when the language server attaches
      local servers = { "pylsp", "tsserver", "nil_ls", "hls" }
      for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
          on_attach = on_attach,
          flags = {
            debounce_text_changes = 150,
          }
        }
      end
    EOF
  '';
  # }}}

  # dunst (Notifications) {{{
  programs.dunst.config = {
    shortcuts = {
        # Shortcuts are specified as [modifier+][modifier+]...key
        # Available modifiers are "ctrl", "mod1" (the alt-key), "mod2",
        # "mod3" and "mod4" (windows-key).
        # Xev might be helpful to find names for keys.

        # Close notification.
        close = "ctrl+space";

        # Close all notifications.
        close_all = "ctrl+shift+space";

        # Redisplay last message(s).
        # On the US keyboard layout "grave" is normally above TAB and left
        # of "1".
        history = "ctrl+grave";

        # Context menu.
        context = "ctrl+shift+period";
    };
  }; # }}}
}
