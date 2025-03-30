{ pkgs-fixed, ... }: {
  home.packages = with pkgs-fixed; [
    vscode
    jetbrains.pycharm-community
    jetbrains.idea-community
    android-studio
  ];
}
