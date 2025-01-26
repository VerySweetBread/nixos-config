{ pkgs, pkgs-unstable, inputs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0" "freeimage-unstable-2021-11-01" "obsidian-1.5.12"];
  };

  environment.systemPackages = with pkgs; [
    file
    tree
    wget
    git
    (btop.override { cudaSupport = true; })
    unzip
    yazi
    zip
    lazygit
    httpie
    ncdu
    tldr
    helix
    pkgs-unstable.home-manager
  ];

  fonts.packages = with pkgs-unstable; [
    jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    ubuntu_font_family
    unifont
    nerd-fonts.symbols-only
    corefonts
  ];
}
