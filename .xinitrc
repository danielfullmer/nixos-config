#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# Start xinitrc stuff
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

eval "`gnome-keyring-daemon`"
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID
export SSH_AUTH_SOCK
export GPG_AGENT_INFO

xrdb -merge "$HOME/.Xresources"
xsettingsd &

xcompmgr &
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 5 --transparent true --tint 0x000000 --height request &
VBoxClient --seamless &

redshift -l 40:111 -t 6000:3700 &
gnome-sound-widget &

xset -dpms
xsetroot -cursor_name left_ptr
xmodmap .Xmodmap

[ -e "$HOME/.xinitrc.local" ] && source "$HOME/.xinitrc.local"

#exec xmonad

sxhkd &
exec bspwm
