ThinkPad T480

CPU: Intel i5-8350U
RAM: 16GB planned (8GB stock + 8GB SO-DIMM)
SSD: 256GB NVMe stock; disko assumes `/dev/nvme0n1`

## Installation notes

This host uses `disko` with GPT + unencrypted EFI System Partition + LUKS + Btrfs subvolumes.

Before formatting, verify the target disk:

```bash
lsblk
```

If the internal drive is not `/dev/nvme0n1`, edit `host/Inaho/disko.nix` first.
For a 2.5" SATA SSD/HDD it will usually be `/dev/sda`.

Then partition, format and mount:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount ./host/Inaho/disko.nix
```

This destroys the selected disk.

After that install the host:

```bash
sudo nixos-install --flake .#Inaho
```

The flake contains a new `disko` input. If `flake.lock` has not been updated yet, run:

```bash
nix flake lock --update-input disko
```

## After first boot

Update firmware, especially BIOS/UEFI and Thunderbolt, when batteries are installed and charged:

```bash
sudo fwupdmgr refresh
sudo fwupdmgr get-updates
sudo fwupdmgr update
```
