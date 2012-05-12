eval "`/usr/bin/dbus-launch --auto-syntax`"

/usr/bin/xmodmap "${HOME}/.xmodmaprc" &
/usr/bin/xcompmgr &
/usr/bin/trayer --height 10 --SetPartialStrut true --SetDockType true --transparent true --tint 0x000000 &

source "${HOME}/.xinitrc.local"

/usr/bin/xmonad
