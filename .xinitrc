eval "`/usr/bin/dbus-launch --auto-syntax`"

eval "`gnome-keyring-daemon`"
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID
export SSH_AUTH_SOCK
export GPG_AGENT_INFO

source "${HOME}/.xinitrc.local"

xset -dpms
xsetroot -cursor_name left_ptr
xmodmap "${HOME}/.xmodmaprc" &

xcompmgr &
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 5 --transparent true --tint 0x000000 --height 20 &
/usr/lib/gnome-settings-daemon/gnome-settings-daemon &

ck-launch-session xmonad
