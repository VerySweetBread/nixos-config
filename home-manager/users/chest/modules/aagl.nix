let
  aagl-gtk-on-nix = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "14fnbcvmr1b8jkkjfbyarljwawgh3as9skdyvyc10b1nqh0641h0";
    }
  );
in
{
  home.packages = [ aagl-gtk-on-nix.the-honkers-railway-launcher ];
}
