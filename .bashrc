#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source "${HOME}/.aliases"

PS1='[\u@\h \W]\$ '

# Load up ipython pysh if available
#which ipython > /dev/null && exec `which ipython` --profile=pysh
