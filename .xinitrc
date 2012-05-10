eval "`/usr/bin/dbus-launch --auto-syntax`"

/usr/bin/xmodmap "${HOME}/.xmodmaprc" &
/usr/libexec/gnome-settings-daemon &
/usr/bin/xcompmgr &

source "${HOME}/.xinitrc.local"

/usr/bin/xmonad
