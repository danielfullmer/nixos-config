eval "`/usr/bin/dbus-launch --auto-syntax`"

/usr/bin/xmodmap "${HOME}/.xmodmaprc" &
/usr/bin/xcompmgr &
/usr/bin/trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 3 --transparent true --tint 0x000000 --height 20 &

source "${HOME}/.xinitrc.local"

/usr/bin/xmonad
