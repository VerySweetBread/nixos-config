let
  aagl-gtk-on-nix = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "06s9swqgqkafv18zl3k5dbc6q8gdm095rhrnpr2xcqk2vriwwzzk";
    }
  );
in
{
  home.packages = [ aagl-gtk-on-nix.the-honkers-railway-launcher ];
}
