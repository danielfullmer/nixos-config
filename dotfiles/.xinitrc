#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# TODO: This file is no longer used. This has been moved to nixos displayManager.sessionCommands
# This is here for reference purposes. I should remove it when the new setup is stable.

# Start xinitrc stuff
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xrdb -merge "$HOME/.Xresources"
xrdb -merge "$HOME/.base16-xresources/base16-tomorrow.dark.256.xresources"
xsettingsd &

if [[ -n "$(dmesg | grep -i virtualbox)" ]]; then
    VBoxClient-all &
else
    compton -c -C -f -D 5 --backend glx --vsync opengl-swc -b &
fi

gnome-sound-widget &

xset -dpms
xsetroot -cursor_name left_ptr
xmodmap .Xmodmap

[ -e "$HOME/.fehbg" ] && source "$HOME/.fehbg"
[ -e "$HOME/.xinitrc.local" ] && source "$HOME/.xinitrc.local"

sxhkd &
rm /tmp/bspwm*
exec bspwm
