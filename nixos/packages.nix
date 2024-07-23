{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0" "freeimage-unstable-2021-11-01"];
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    google-chrome
    telegram-desktop
    alacritty
    obs-studio
    rofi
    wofi
    mpv
    kdenlive
    gparted
    obsidian
    zoom-us
    pcmanfm-qt
    vscode
    jetbrains.pycharm-community
    jetbrains.idea-community
    android-studio
    thunderbird

    # Coding stuff
    gnumake
    gcc
    nodejs
    python
    (python3.withPackages (ps: with ps; [ requests bpython ]))
    python311Packages.pip
    rocmPackages.llvm.clang-tools-extra
    rocmPackages.llvm.clang
    ncurses
    
    # CLI utils
    uwufetch
    file
    tree
    wget
    git
    fastfetch
    btop 
    nix-index
    unzip
    scrot
    ffmpeg
    light
    lux
    mediainfo
    yazi
    zram-generator
    zip
    ntfs3g
    yt-dlp
    brightnessctl
    swww
    openssl
    lazygit
    bluez
    bluez-tools
    httpie
    ncdu
    hexyl
    jq
    tldr
    bat
    xdg-utils
    helix
    playerctl

    # GUI utils
    feh
    imv
    dmenu
    screenkey
    mako
    gromit-mpx

    # Xorg stuff
    #xterm
    #xclip
    #xorg.xbacklight

    # Wayland stuff
    xwayland
    wl-clipboard
    cliphist
    ueberzugpp

    # WMs and stuff
    herbstluftwm
    hyprland
    seatd
    xdg-desktop-portal-hyprland
    polybar
    waybar
    waypaper
    vesktop
    lxqt.lxqt-policykit
    hyprcursor

    # Sound
    pipewire
    pulseaudio
    pamixer

    # GPU stuff 
    rocm-opencl-icd
    glaxnimate

    # Screenshotting
    grim
    grimblast
    slurp
    flameshot
    swappy

    # Other
    home-manager
    spice-vdagent
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    papirus-nord
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
