{ pkgs-fixed, ... }: {
  home.packages = with pkgs-fixed; [
    (blender.override { cudaSupport = true; })
    aseprite
  ];
}
