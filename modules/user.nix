{ config, lib, ... }: {
  imports = [
    ./user/qt.nix
    ./user/sops.nix
    ./user/neofetch.nix
    ./user/yazi.nix
    ./user/ags.nix
    ./user/zsh.nix
    ./user/helix.nix
    ./user/hyprlock.nix
    ./user/btop.nix
    ./user/wofi.nix
    ./user/mako.nix
    ./user/ghostty.nix
    ./user/packages/art.nix
    ./user/packages/desktop.nix
    ./user/packages/coding.nix
    ./user/packages/utils.nix
  ] ;
}
