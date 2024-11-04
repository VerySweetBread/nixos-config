{ pkgs, ... }: {
  imports = [
    ../../modules/bundle.nix
    ../../modules/hyprlock.nix

    ../../packages/coding.nix
    ../../packages/desktop.nix
    ../../packages/utils.nix
    ../../packages/art.nix

    ./modules/git.nix
    ./modules/hyprland.nix
    ./modules/style.nix
    ./modules/waybar.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "sweetbread";
    homeDirectory = "/home/sweetbread";
    stateVersion = "23.11";
  };

  services.syncthing.enable = true;
}
