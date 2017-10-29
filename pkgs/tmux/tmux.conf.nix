{ pkgs }:

let
  tmux-fingers = pkgs.fetchFromGitHub {
    owner = "Morantron";
    repo = "tmux-fingers";
    rev = "0.6.2";
    sha256 = "1k46wx1c1m5xvis98cwngjz25v1vjphy82176dibq4wz8j265h9y";
  };
in
''
set-option -g prefix C-a

set-option -g set-titles on
set-option -g set-titles-string '#{pane_title}'
set-option -g default-terminal "screen-256color"

set-option -g base-index 1
set-option -g repeat-time 750
set-option -g escape-time 50
set-option -g mouse on
set-option -g terminal-overrides 'xterm*:smcup@:rmcup@'
set-option -g mode-keys vi

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
bind-key -n M-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
bind-key -n M-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
bind-key -n M-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
bind-key -n M-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
bind-key -n M-\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
bind-key -T copy-mode-vi M-h select-pane -L
bind-key -T copy-mode-vi M-j select-pane -D
bind-key -T copy-mode-vi M-k select-pane -U
bind-key -T copy-mode-vi M-l select-pane -R
bind-key -T copy-mode-vi M-\ select-pane -l

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

##

# Default binding is: C-a F
# TODO: It's broken at the moment.
# run-shell tmux-fingers/tmux-fingers.tmux
# set-option -g @fingers-copy-command 'yank'

source-file ${./tmux.line}
''
