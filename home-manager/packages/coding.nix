{ pkgs, pkgs-stable, ... }: {
  home.packages = with pkgs-stable; [
    vscode
    jetbrains.pycharm-community
    jetbrains.idea-community
    android-studio
  ] ++ ( with pkgs; [
    cmake
    gnumake
    nodejs
    (python3.withPackages (ps: with ps; [ requests bpython ]))
    python311Packages.pip
    rocmPackages.llvm.clang-tools-extra
    rocmPackages.llvm.clang
    ncurses
  ]);
}
