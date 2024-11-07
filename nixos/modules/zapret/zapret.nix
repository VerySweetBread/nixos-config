{ pkgs, ... }: {
  disabledModules = [ "services/networking/zapret.nix" ]; # необходимо если версия nixpkgs новее 5a5c04d

  imports = [ ./zapret_service.nix ];

  services.zapret = {
    enable = true;
    mode = "nfqws";

    settings = ''
QUIC_PORTS=50000-65535
NFQWS_OPT_DESYNC="--dpi-desync=split2 --dpi-desync-ttl=1 --wssize 1:6"
NFQWS_OPT_DESYNC_QUIC="--dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-any-protocol"
    '';
  };
}
