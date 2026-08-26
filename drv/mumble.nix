{ lib
, pkgs
, mumble ? pkgs.mumble
}:

let
  # PipeWire 1.4.0 removed client-rt.conf, changing how clients negotiate
  # realtime scheduling. Mumble never adapted, so its PipeWire data-loop
  # thread stalls mid-negotiation and its own RT watchdog SIGKILLs the
  # whole process almost immediately on every launch (confirmed via
  # bpftrace: signal_generate shows Mumble's own "data-loop.0" thread
  # sending itself SIGKILL). Reproduced identically on both the packaged
  # 1.5.915 (Qt5) and a from-source 1.6.870 RC (Qt6) build, so it's the
  # shared PipeWire client integration at fault, not Mumble's UI stack.
  #
  # Upstream: https://github.com/mumble-voip/mumble/issues/6780
  # Bisected there to PipeWire 1.2.7 (last known-good) vs 1.4.1+ (broken).
  #
  # Fix: give Mumble an old, compatible libpipewire-0.3.so to dlopen at
  # runtime. The system's actual PipeWire daemon is untouched (still
  # whatever version NixOS ships) - only the client library Mumble talks
  # through is pinned back.
  pipewireGoodPkgs = import (fetchTarball {
    url = "https://channels.nixos.org/nixos-24.11/nixexprs.tar.xz";
    sha256 = "189lwv8l10bm9fnksfkzy05pm86gmziy9z3bdn13zc8d636ylchj"; # nix-prefetch-url --unpack https://channels.nixos.org/nixos-24.11/nixexprs.tar.xz
  }) { inherit (pkgs) system; };
  pipewireGood = pipewireGoodPkgs.pipewire;

  # Mumble's own build is Qt5-based; QT_PLUGIN_PATH isn't set by its
  # wrapper for the platform/sql plugins mumble actually needs when we
  # bypass that wrapper below, so it has to be supplied explicitly.
  qt5PluginPath = lib.makeSearchPath "lib/qt-${pkgs.qt5.qtbase.version}/plugins" [
    pkgs.qt5.qtbase.bin
    pkgs.qt5.qtsvg.bin
    pkgs.qt5.qtwayland.bin
  ];
in
pkgs.symlinkJoin {
  name = "mumble-pipewire-fixed-${mumble.version}";

  paths = [ mumble ];

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # mumble's own wrapper always prepends its own (broken, too-new)
  # PipeWire path in front of anything we set, so wrapping it a second
  # time can't win that ordering fight. Instead we skip straight to the
  # real unwrapped binary and set env ourselves.
  postBuild = ''
    rm -f $out/bin/mumble
    makeWrapper ${mumble}/bin/.mumble-wrapped $out/bin/mumble \
      --prefix LD_LIBRARY_PATH : "${pipewireGood}/lib" \
      --set QT_PLUGIN_PATH "${qt5PluginPath}"
  '';

  meta = mumble.meta // {
    description = mumble.meta.description
      + " (patched: pinned PipeWire client lib to 1.2.7 to work around SIGKILL-on-launch with PipeWire >=1.4.0, see mumble#6780)";
  };
}