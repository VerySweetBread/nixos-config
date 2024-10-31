{ pkgs, inputs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0" "freeimage-unstable-2021-11-01" "obsidian-1.5.12"];
  };

  environment.systemPackages = with pkgs; [
    # CLI utils
    file
    tree
    wget
    git
    btop 
    nix-index
    unzip
    yazi
    zram-generator
    zip
    ntfs3g
    openssl
    lazygit
    bluez
    bluez-tools
    httpie
    ncdu
    hexyl
    jq
    tldr
    xdg-utils
    helix
    playerctl
    duf
    v2raya

    # GUI utils
    feh
    imv
    gromit-mpx
    notify-desktop

    # Wayland stuff
    xwayland
    wl-clipboard
    cliphist
    ueberzugpp

    # WMs and stuff
    hyprland
    seatd
    xdg-desktop-portal-hyprland
    waybar
    waypaper
    lxqt.lxqt-policykit
    hyprcursor

    # Sound
    pipewire
    pulseaudio
    pamixer

    # GPU stuff 
    glaxnimate

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
    ubuntu_font_family
    unifont
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
