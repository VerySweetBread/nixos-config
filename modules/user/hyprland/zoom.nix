{
  wayland.windowManager.hyprland.settings = {
    bind = [
      # "$mainMod, mouse_down, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
      # "$mainMod, mouse_up  , exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"

      "$mainMod SHIFT, mouse_up   , exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mainMod SHIFT, mouse_down , exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mainMod SHIFT, minus      , exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mainMod SHIFT, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor 1"
      "$mainMod SHIFT, 0          , exec, hyprctl -q keyword cursor:zoom_factor 1"
    ];

    binde = [
      "$mainMod, equal      , exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
      "$mainMod, minus      , exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
      "$mainMod, KP_ADD     , exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float * 1.1')"
      "$mainMod, KP_SUBTRACT, exec, hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '(.float * 0.9) | if . < 1 then 1 else . end')"
    ];
  };
}