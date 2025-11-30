{ pkgs, ... }: {
  boot = {
    loader = {
      timeout = 3;
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
      
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
    };
    consoleLogLevel = 0;
    kernelParams = [
      # "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      # "rd.systemd.show_status=false"
      # "rd.udev.log_level=3"
      "udev.log_priority=0"
    ];
    plymouth = {
      enable = true;
      theme = "black_hud";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "black_hud" ];
        })
      ];
    };
  };
}
