{ config, lib, pkgs, ... }: let
  pythonValidityPatch = pkgs.writeText "python-validity-python-3.14.patch" ''
    diff --git a/validitysensor/flash.py b/validitysensor/flash.py
    index d37f15a..be3d4a1 100644
    --- a/validitysensor/flash.py
    +++ b/validitysensor/flash.py
    @@ -34,6 +34,10 @@ def get_flash_info():
         rsp = tls.cmd(unhex('3e'))
         assert_status(rsp)
         rsp = rsp[2:]
    +    if len(rsp) < 0xe:
    +        # An uninitialised 06cb:009a returns only the success status word.
    +        # Let init_flash() format it instead of failing in struct.unpack().
    +        return FlashInfo(None, 0, 0, 0, 0, [])
         hdr = rsp[:0xe]
         rsp = rsp[0xe:]
         jid0, jid1, blocks, unknown0, blocksize, unknown1, pcnt = unpack('<HHHHHHH', hdr)
    diff --git a/validitysensor/init.py b/validitysensor/init.py
    index 18890c5..710668c 100644
    --- a/validitysensor/init.py
    +++ b/validitysensor/init.py
    @@ -25,8 +25,8 @@ def close():

     def open_common():
         init_data_dir()
    -    init_flash()
         usb.send_init()
    +    init_flash()
         tls.parse_tls_flash(read_tls_flash())
         tls.open()
         upload_fwext()
    diff --git a/validitysensor/usb.py b/validitysensor/usb.py
    index 9db2b07..353b2c7 100644
    --- a/validitysensor/usb.py
    +++ b/validitysensor/usb.py
    @@ -1,6 +1,7 @@
     import errno
     import logging
    +import time
     import typing
     from binascii import hexlify, unhexlify
     from enum import Enum
     from struct import unpack
    @@ -68,22 +69,32 @@ class Usb:
         def close(self):
             if self.dev is not None:
                 try:
                     self.dev.reset()
                     self.dev = None
                 except:
                     pass
    ${" "}
         def usb_dev(self):
             return self.dev
    ${" "}
    +    def cmd_retry_busy(self, command: bytes):
    +        # Metallica sensors can report 0x0104 for a few seconds after wake-up.
    +        for _ in range(20):
    +            rsp = self.cmd(command)
    +            status, = unpack('<H', rsp[:2])
    +            if status != 0x0104:
    +                return rsp
    +            time.sleep(0.5)
    +        return rsp
    +
         def send_init(self):
             # self.dev.set_configuration()
    ${" "}
             # TODO analyse responses, detect hardware type
    -        assert_status(self.cmd(unhexlify('01')))  # RomInfo.get()
    +        assert_status(self.cmd_retry_busy(unhexlify('01')))  # RomInfo.get()
             assert_status(self.cmd(unhexlify('19')))
    ${" "}
             # 43 -- get partition header(?) (02 -- fwext partition)
             # c28c745a in response is a FwextBuildtime = 0x5A748CC2
    -        rsp = self.cmd(unhexlify('4302'))  # get_fw_info()
    +        rsp = self.cmd_retry_busy(unhexlify('4302'))  # get_fw_info()
    ${" "}
  '';

  python-validity = pkgs.python3Packages.buildPythonApplication rec {
    pname = "python-validity";
    version = "0.15-unstable-2020-12-14";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "uunicorn";
      repo = "python-validity";
      rev = "a6bbc21dce7b8b3c3cd92378a0b2579a2fb45920";
      hash = "sha256-RflX7e6nd11pSg8mh3mjZiVGNUSdox/SKXHR4W+PhMs=";
    };

    postPatch = ''
      ${lib.getExe pkgs.gitMinimal} apply ${pythonValidityPatch}
    '';

    build-system = [ pkgs.python3Packages.setuptools ];

    dependencies = with pkgs.python3Packages; [
      cryptography
      dbus-python
      pygobject3
      pyusb
      pyyaml
    ];

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postInstall = ''
      install -Dm755 dbus_service/dbus-service \
        "$out/lib/python-validity/dbus-service"
      install -Dm644 dbus_service/io.github.uunicorn.Fprint.conf \
        "$out/share/dbus-1/system.d/io.github.uunicorn.Fprint.conf"

      install -Dm755 dbus_service/dbus-service \
        "$out/bin/python-validity-service"
      install -Dm755 scripts/factory-reset.py \
        "$out/bin/validity-factory-reset"

      install -d "$out/share/python-validity/playground"
      install -m755 \
        scripts/dbus-cmd.py \
        scripts/lsdbus.py \
        scripts/factory-reset.py \
        scripts/prototype.py \
        "$out/share/python-validity/playground/"
    '';

    postFixup = ''
      wrapProgram "$out/bin/validity-sensors-firmware" \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.findutils
          pkgs.innoextract
        ]}
    '';

    # Upstream does not have an automated test suite.
    doCheck = false;

    meta = {
      description = "Userspace driver for Validity and Synaptics fingerprint sensors";
      homepage = "https://github.com/uunicorn/python-validity";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };

  fprintd-clients = pkgs.runCommand "fprintd-clients" { } ''
    mkdir -p "$out/bin"
    for client in fprintd-delete fprintd-enroll fprintd-list fprintd-verify; do
      ln -s "${pkgs.fprintd}/bin/$client" "$out/bin/$client"
    done
  '';

  sleepTargets = [
    "suspend.target"
    "hibernate.target"
    "hybrid-sleep.target"
    "suspend-then-hibernate.target"
  ];
in {
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

    # The T480's 06cb:009a reader needs python-validity as a backend for
    # open-fprintd. Upstream fprintd/libfprint cannot drive this sensor.
    fprintd = {
      enable = false;
      package = pkgs.fprintd;
    };

    dbus.packages = [
      pkgs.open-fprintd
      python-validity
    ];

    logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchExternalPower = "suspend-then-hibernate";
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

  security.pam.services = lib.genAttrs [
    "greetd"
    "hyprlock"
    "login"
    "polkit-1"
    "sudo"
  ] (_: { fprintAuth = true; });

  systemd.services = {
    open-fprintd = {
      description = "Open FPrint daemon";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "dbus";
        BusName = "net.reactivated.Fprint";
        ExecStart = "${pkgs.open-fprintd}/lib/open-fprintd/open-fprintd";
        Restart = "on-failure";
      };
    };

    python3-validity = {
      description = "python-validity fingerprint sensor backend";
      wantedBy = [ "multi-user.target" ];
      after = [ "open-fprintd.service" ];
      wants = [ "open-fprintd.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${python-validity}/bin/python-validity-service";
        Restart = "always";
        RestartSec = 2;
        RuntimeDirectory = "python-validity";
        RuntimeDirectoryMode = "0700";
        RuntimeDirectoryPreserve = "yes";
      };
    };

    open-fprintd-suspend = {
      description = "Suspend open-fprintd backends";
      wantedBy = sleepTargets;
      before = sleepTargets;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.open-fprintd}/lib/open-fprintd/suspend.py";
      };
    };

    open-fprintd-resume = {
      description = "Resume open-fprintd backends";
      wantedBy = sleepTargets;
      after = sleepTargets;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.open-fprintd}/lib/open-fprintd/resume.py";
      };
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
    fprintd-clients
    python-validity
  ];
}
