{ config, lib, pkgs, ... }: {
  # T480-specific hardware defaults.
  hardware = {
    enableRedistributableFirmware = true;

    trackpoint = {
      enable = true;
      emulateWheel = true;
    };
  };

  boot = {
    supportedFilesystems = [ "btrfs" ];

    initrd.availableKernelModules = [
      "nvme"
      "ahci"
      "xhci_pci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];

    kernelModules = [ "kvm-intel" "thinkpad_acpi" ];

    kernelParams = [
      # Prefer S3/deep sleep when BIOS exposes it. If suspend behaves worse,
      # remove this and use the BIOS sleep setting instead.
      "mem_sleep_default=deep"
    ];
  };

  powerManagement.enable = true;
  services = {
    # Firmware updates for BIOS/UEFI, Thunderbolt, SSDs where LVFS supports it.
    fwupd.enable = true;

    # Helps Intel laptops keep sane thermal behaviour under load.
    thermald.enable = true;

    # Fingerprint reader support. If fprintd does not detect the reader,
    # leaving this enabled is harmless; login can still use a password.
    fprintd.enable = true;

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandlePowerKey = "poweroff";
    };

    tlp.settings = {
      # Preserve batteries when the laptop is usually on AC.
      # Raise STOP_* to 100 if maximum autonomy matters more than battery wear.
      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0 = 95;
      START_CHARGE_THRESH_BAT1 = 70;
      STOP_CHARGE_THRESH_BAT1 = 85;
      RESTORE_THRESHOLDS_ON_BAT = 1;

      # NVMe/SATA SSD power saving without making the system too sluggish.
      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";

      # Usually safe on ThinkPads; disable if some USB device randomly disconnects.
      USB_AUTOSUSPEND = 1;
    };
  };

  networking.networkmanager.wifi.powersave = true;

  environment.systemPackages = with pkgs; [
    acpi
    lm_sensors
    pciutils
    powertop
    smartmontools
    usbutils
    nvme-cli
  ];
}
