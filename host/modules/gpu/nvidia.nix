{ config, pkgs-stable, lib, ... }: {
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs-stable; [
        nvidia-vaapi-driver
        intel-media-driver
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs-stable.pkgsi686Linux; [nvidia-vaapi-driver intel-media-driver];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = lib.optionalAttrs config.host.laptop {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = 1;
    WLR_DRM_NO_ATOMIC = 1;
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = 1;
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = 1;
  };
}
