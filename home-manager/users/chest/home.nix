{ pkgs, pkgs-stable, ... }: {
  imports = [
    ../../modules/bundle.nix
    
    ../../packages/art.nix
    ../../packages/desktop.nix
    ../../packages/utils.nix

    ./modules/git.nix
    ./modules/hyprland.nix
    ./modules/style.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "chest";
    homeDirectory = "/home/chest";
    stateVersion = "23.11";

    packages = with pkgs; [
      nautilus
    ] ++ (with pkgs-stable; [
      jetbrains.pycharm-community
    ]);
  };
}
