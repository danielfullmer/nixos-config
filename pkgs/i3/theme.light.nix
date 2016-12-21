{ colors }:

with colors; ''
# ~/.i3/config
# i3 config template
# Base16 <%- scheme %> by <%- author %>
# template by Matt Parnell, @parnmatt

set $base00 #${base00}
set $base01 #${base01}
set $base02 #${base02}
set $base03 #${base03}
set $base04 #${base04}
set $base05 #${base05}
set $base06 #${base06}
set $base07 #${base07}
set $base08 #${base08}
set $base09 #${base09}
set $base0A #${base0A}
set $base0B #${base0B}
set $base0C #${base0C}
set $base0D #${base0D}
set $base0E #${base0E}
set $base0F #${base0F}

client.focused $base0D $base0D $base07 $base06
client.focused_inactive $base05 $base05 $base04 $base06
client.unfocused $base06 $base06 $base04 $base06
client.urgent $base05 $base08 $base00 $base08
''
