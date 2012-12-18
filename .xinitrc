eval "`/usr/bin/dbus-launch --auto-syntax`"

eval "`gnome-keyring-daemon`"
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID
export SSH_AUTH_SOCK
export GPG_AGENT_INFO

[[ -e "${HOME}/.xinitrc.local" ]] && source "${HOME}/.xinitrc.local"

xset -dpms
xsetroot -cursor_name left_ptr
xmodmap "${HOME}/.xmodmaprc" &

xcompmgr &
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype percent --width 5 --transparent true --tint 0x000000 --height request &
/usr/lib/gnome-settings-daemon/gnome-settings-daemon &

redshift -l 40.23:111.66 &

ck-launch-session xmonad
