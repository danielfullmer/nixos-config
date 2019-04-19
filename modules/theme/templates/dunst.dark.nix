{ colors }:

with colors; {
  global = {
    frame_color = "\"#${base05}\"";
    separator_color = "\"#${base05}\"";
  };

  urgency_low = {
    background = "\"#${base00}\"";
    foreground = "\"#${base07}\"";
  };

  urgency_normal = {
    background = "\"#${base00}\"";
    foreground = "\"#${base0D}\"";
  };

  urgency_critical = {
    background = "\"#${base00}\"";
    foreground = "\"#${base08}\"";
  };
}
