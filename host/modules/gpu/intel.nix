{ config, pkgs-stable, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs-stable; [
      intel-media-driver
      intel-compute-runtime
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs-stable.pkgsi686Linux; [
      intel-media-driver
    ];
  };

  nixpkgs.config.packageOverrides = pkgs-stable: {
    vaapiIntel = pkgs-stable.vaapiIntel.override { enableHybridCodec = true; };
  };

  environment.systemPackages = with pkgs-stable; [
    intel-gpu-tools
    libva-utils
    clinfo
  ];

  boot.kernelParams = [ "i915.force_probe=*" ];
}
