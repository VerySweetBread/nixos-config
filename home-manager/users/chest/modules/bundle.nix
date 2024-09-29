{
  imports = [
    ./git.nix
    ./alacritty.nix
    ./qt.nix
    # ./sops.nix
    ./style.nix
    ./aagl.nix

    ./wms/hyprland.nix
    ./wms/waybar.nix
    ./wms/wofi.nix
    ./wms/mako.nix
  ];
}
