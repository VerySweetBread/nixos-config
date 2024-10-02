{ pkgs, config, ... }: {
  imports = [(
    import ../../../patterns/waybar.nix {
      inherit pkgs;
      inherit config;
      active_color = "#${config.lib.stylix.colors.base0B}";
    }
  )];
}
