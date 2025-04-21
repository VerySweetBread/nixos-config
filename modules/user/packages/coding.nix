{ pkgs-stable, ... }: {
  home.packages = with pkgs-stable; [
    vscode
    jetbrains.pycharm-community
    jetbrains.idea-community
    android-studio
  ];
}
