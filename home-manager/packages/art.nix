{ pkgs-stable, ... }: {
  home.packages = with pkgs-stable; [
    (blender.override { cudaSupport = true; })
    aseprite
  ];
}
