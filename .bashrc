#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source "${HOME}/.aliases"

PS1='[\u@\h \W]\$ '

#exec `which ipython` --profile=pysh --no-confirm-exit --no-banner
