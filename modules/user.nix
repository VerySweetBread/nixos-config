{ config, lib, ... }: {
  imports = [
    ./user/ags.nix
    ./user/btop.nix
    ./user/fuzzel.nix
    ./user/ghostty.nix
    ./user/helix.nix
    ./user/hyprland.nix
    ./user/hyprlock.nix
    ./user/mako.nix
    ./user/neofetch.nix
    ./user/qt.nix
    ./user/sops.nix
    ./user/yazi.nix
    ./user/zsh.nix

    ./user/packages/art.nix
    ./user/packages/desktop.nix
    ./user/packages/coding.nix
    ./user/packages/utils.nix
  ];
}
