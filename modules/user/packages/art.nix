{ pkgs-fixed, lib, host, ... }:

lib.mkIf (!host.laptop) {
  home.packages = with pkgs-fixed; [
    (blender.override { cudaSupport = true; })
    aseprite
    krita
    gimp
  ];
}
