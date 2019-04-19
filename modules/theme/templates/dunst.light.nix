{ colors }:

with colors; {
  global = {
    frame_color = "\"#${base05}\"";
    separator_color = "\"#${base05}\"";
  };
  urgency_low = {
    background = "\"#${base07}\"";
    foreground = "\"#${base02}\"";
  };

  urgency_normal = {
    background = "\"#${base07}\"";
    foreground = "\"#${base0D}\"";
  };

  urgency_critical = {
    background = "\"#${base07}\"";
    foreground = "\"#${base08}\"";
  };
}
