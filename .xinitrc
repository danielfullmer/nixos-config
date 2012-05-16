eval "`/usr/bin/dbus-launch --auto-syntax`"

source "${HOME}/.xinitrc.local"

xset -dpms
xsetroot -cursor_name left_ptr
xmodmap "${HOME}/.xmodmaprc" &

xcompmgr &
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 5 --transparent true --tint 0x000000 --height 20 &

ck-launch-session /usr/bin/xmonad
