{ pkgs, inputs, ... }: {
  imports = [
    ./zsh.nix
    ./modules/bundle.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "sweetbread";
    homeDirectory = "/home/sweetbread";
    stateVersion = "23.11";

    packages = with pkgs; [
      # Desktop apps
      google-chrome
      # inputs.ayugram-desktop.packages.${pkgs.system}.default
      telegram-desktop
      vesktop
      obs-studio
      mpv
      obsidian
      vscode
      jetbrains.pycharm-community
      jetbrains.idea-community
      android-studio
      thunderbird
    
      # Coding stuff
      cmake
      gnumake
      nodejs
      (python3.withPackages (ps: with ps; [ requests bpython ]))
      python311Packages.pip
      rocmPackages.llvm.clang-tools-extra
      rocmPackages.llvm.clang
      ncurses

      # CLI utils
      scrot
      ffmpeg
      yt-dlp
      bat

      # GUI utils
      feh
      imv
      gromit-mpx
      notify-desktop
    ];
  };
}
