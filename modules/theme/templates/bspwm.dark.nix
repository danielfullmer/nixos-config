{ bspwm, colors }:

with colors; ''
# ~/.bspwm/bspwmrc
# bspwm config template
# Base16 <%- scheme %> by <%- author %>
# template by Luke Jones @luke-nukem

${bspwm}/bin/bspc config active_border_color \#${base04}
${bspwm}/bin/bspc config normal_border_color \#${base02}
${bspwm}/bin/bspc config focused_border_color \#${base08}
${bspwm}/bin/bspc config presel_feedback_color \#${base08}
${bspwm}/bin/bspc config normal_locked_border_color \#${base0B}
${bspwm}/bin/bspc config focused_locked_border_color \#${base0B}
${bspwm}/bin/bspc config normal_sticky_border_color \#${base09}
${bspwm}/bin/bspc config focused_sticky_border_color \#${base09}
${bspwm}/bin/bspc config normal_private_border_color \#${base01}
${bspwm}/bin/bspc config focused_private_border_color \#${base01}
''
