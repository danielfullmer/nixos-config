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

eval $(gpg-agent --daemon --enable-ssh-support)

xrdb -merge "$HOME/.Xresources"
xrdb -merge "$HOME/.base16-xresources/base16-tomorrow.dark.256.xresources"
xsettingsd &

compton -c -C -f -D 5 --backend glx --vsync opengl-swc -b
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 5 --transparent true --tint 0x000000 --height request &
VBoxClient --seamless &

gnome-sound-widget &

xset -dpms
xsetroot -cursor_name left_ptr
xmodmap .Xmodmap

[ -e "$HOME/.fehbg" ] && source "$HOME/.fehbg"
[ -e "$HOME/.xinitrc.local" ] && source "$HOME/.xinitrc.local"

sxhkd &
rm /tmp/bspwm*
exec bspwm
