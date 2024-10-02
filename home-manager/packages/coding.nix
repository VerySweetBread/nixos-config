{ pkgs, ... }: {
  home.packages = with pkgs; [
    vscode
    jetbrains.pycharm-community
    jetbrains.idea-community
    android-studio

    cmake
    gnumake
    nodejs
    (python3.withPackages (ps: with ps; [ requests bpython ]))
    python311Packages.pip
    rocmPackages.llvm.clang-tools-extra
    rocmPackages.llvm.clang
    ncurses
  ];
}
