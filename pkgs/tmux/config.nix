{ config, ... }:
{
  programs.tmux.config = ''
    set-option -g set-titles on
    set-option -g set-titles-string '#{pane_title}'
    set-option -g default-terminal "tmux-256color"
    set-option -ga terminal-overrides ",*256col*:Tc"

    set-option -g base-index 1
    set-option -g repeat-time 750
    set-option -g escape-time 50
    set-option -g mouse on
    set-option -g terminal-overrides 'xterm*:smcup@:rmcup@'
    set-option -g mode-keys vi

    source-file ${./tmux.line}
  '';
}
