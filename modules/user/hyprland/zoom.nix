{ lib, ... }:
let
  hyprLua = import ./lua.nix { inherit lib; };
  inherit (hyprLua) bind bindWithFlags;

  resetZoom = ''function()
    hl.config({ cursor = { zoom_factor = 1 } })
  end'';

  zoomIn = ''function()
    local current = hl.get_config("cursor.zoom_factor")
    hl.config({ cursor = { zoom_factor = current * 1.1 } })
  end'';

  zoomOut = ''function()
    local current = hl.get_config("cursor.zoom_factor")
    hl.config({ cursor = { zoom_factor = math.max(1, current * 0.9) } })
  end'';
in {
  lucidHyprlandBinds = [
    (bind "SUPER + SHIFT + mouse_up" resetZoom)
    (bind "SUPER + SHIFT + mouse_down" resetZoom)
    (bind "SUPER + SHIFT + minus" resetZoom)
    (bind "SUPER + SHIFT + KP_SUBTRACT" resetZoom)
    (bind "SUPER + SHIFT + 0" resetZoom)

    (bindWithFlags "SUPER + equal" zoomIn { repeating = true; })
    (bindWithFlags "SUPER + minus" zoomOut { repeating = true; })
    (bindWithFlags "SUPER + KP_ADD" zoomIn { repeating = true; })
    (bindWithFlags "SUPER + KP_SUBTRACT" zoomOut { repeating = true; })
  ];
}
