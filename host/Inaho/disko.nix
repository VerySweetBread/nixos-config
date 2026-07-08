{ lib, ... }:

let
  # Verify with `lsblk` before running disko. For the stock T480 NVMe setup
  # this is usually correct; for a 2.5" SATA SSD/HDD change it to /dev/sda.
  disk = "/dev/sda";

  btrfsMountOptions = [
    "compress=zstd"
    "noatime"
    "ssd"
    "discard=async"
  ];
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            luks = {
              priority = 2;
              name = "cryptsystem";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  # Allows fstrim/discard through LUKS for SSDs.
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" "-L" "NixOS" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = btrfsMountOptions;
                    };

                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = btrfsMountOptions;
                    };

                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsMountOptions;
                    };

                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = btrfsMountOptions;
                    };

                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
