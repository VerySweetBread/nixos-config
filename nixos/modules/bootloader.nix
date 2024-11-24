{ pkgs, ... }: {
  boot = {
    loader = {
      timeout = 3;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      verbose = false;
      # systemd.enable = true;
    };
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=0"
    ];
    plymouth = {
      enable = true;
      theme = "black_hud";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "black_hud" ];
        })
      ];
    };
  };
}
