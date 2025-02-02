{ pkgs, inputs, ... }: {
  nixpkgs.config.allowUnfree = true;

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
  ];

  fonts.packages = with pkgs; [
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
