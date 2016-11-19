{ pkgs, theme }:

with (import ./panel_colors.nix { inherit theme; });
pkgs.writeScript "panel" ''
#!/bin/sh
export PANEL_FIFO="/run/user/$UID/panel_fifo"
export PANEL_HEIGHT="20"

if [ $(pgrep -cx panel) -gt 1 ] ; then
	printf "%s\n" "The panel is already running." >&2
	exit 1
fi

trap 'trap - TERM; kill 0' INT TERM QUIT EXIT

[ -e "$PANEL_FIFO" ] && rm "$PANEL_FIFO"
mkfifo "$PANEL_FIFO"

${pkgs.bspwm}/bin/bspc config top_padding $PANEL_HEIGHT
${pkgs.bspwm}/bin/bspc subscribe > "$PANEL_FIFO" &
${pkgs.xtitle}/bin/xtitle -sf 'T%s' > "$PANEL_FIFO" &
#${pkgs.conky}/bin/conky -c ${./conkyrc} > "$PANEL_FIFO" &

${import ./panel_bar.nix { inherit pkgs theme; }} < "$PANEL_FIFO" | \
    ${pkgs.bar-xft}/bin/lemonbar \
        -f "${theme.fontName}" -f "FontAwesome" \
        -F "${COLOR_FOREGROUND}" \
        -B "${COLOR_BACKGROUND}" \
    | while read line; do eval "$line"; done &

wait
''
