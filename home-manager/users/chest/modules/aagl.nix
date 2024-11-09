let
  aagl-gtk-on-nix = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "172nwbkix2wx3sq7z1mchm1awmy5klvcmsn54jylx85nypx67wzx";
    }
  );
in
{
  home.packages = [ aagl-gtk-on-nix.the-honkers-railway-launcher ];
}
