{ pkgs-fixed, lib, osConfig, ... }:

lib.mkIf (!osConfig.host.laptop) {
  home.packages = with pkgs-fixed; [
    (blender.override { cudaSupport = true; })
    aseprite
    krita
    gimp
  ];
}
