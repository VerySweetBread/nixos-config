{ pkgs-pinned, lib, osConfig, ... }:

lib.mkIf (!osConfig.host.laptop) {
  home.packages = with pkgs-pinned; [
    (blender.override { cudaSupport = true; })
    aseprite
    krita
    gimp
  ];
}
