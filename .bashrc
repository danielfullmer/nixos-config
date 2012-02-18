#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias vdmplayer='mplayer -vc ffh264vdpau -vo vdpau'
alias vi='vim'

PS1='[\u@\h \W]\$ '
