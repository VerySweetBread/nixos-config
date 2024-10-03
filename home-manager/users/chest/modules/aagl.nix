let
  aagl-gtk-on-nix = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "1h96br2xrxrzf46n6qa7c393qxh335dp6x0qfdzcyb8va7dj42c9";
    }
  );
in
{
  home.packages = [ aagl-gtk-on-nix.the-honkers-railway-launcher ];
}
