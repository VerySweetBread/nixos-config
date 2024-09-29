let
  aagl-gtk-on-nix = import (
    builtins.fetchTarball {
      url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
      sha256 = "023yqdxs83cxx39kl7cawwyr39c1qnnv4n99igpsm2a5yay3wmsa";
    }
  );
in {
  home.packages = [ aagl-gtk-on-nix.the-honkers-railway-launcher ];
}
