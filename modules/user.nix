{ config, lib, ... }: {
  imports = [
    ./user/btop.nix
    ./user/ghostty.nix
    ./user/helix.nix
    ./user/hyprland.nix
    ./user/hyprlock.nix
    ../user/sweetbread/modules/lucid.nix
    ./user/mako.nix
    ./user/neofetch.nix
    ./user/qt.nix
    ./user/quickshell.nix
    ./user/stylix.nix
    ./user/sops.nix
    ./user/ssh.nix
    ./user/walker.nix
    ./user/wob.nix
    ./user/yazi.nix
    ./user/zsh.nix

    ./user/packages/art.nix
    ./user/packages/desktop.nix
    ./user/packages/utils.nix
  ];
}
