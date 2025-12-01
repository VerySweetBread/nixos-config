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
    pinentry-gnome3
  ];

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      jetbrains-mono          # Best mono font
      noto-fonts-cjk-sans     # Japanese
      powerline-symbols       # Console decoration
      unifont                 # Other
    ];
  };
}
