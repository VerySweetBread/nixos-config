{ pkgs, ... }: {
  home.packages = with pkgs; [
    jetbrains.idea-oss
    android-studio
  ];
}
