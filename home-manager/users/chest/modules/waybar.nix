{ pkgs, config, ... }: {
  imports = [(
    import ../../../patterns/waybar.nix {
      inherit pkgs;
      inherit config;
      active_color = "#d197d9";
    }
  )];
}
