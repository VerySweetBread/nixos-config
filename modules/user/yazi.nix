{ pkgs, lib, inputs, ... }: let
  hostSystem = pkgs.stdenv.hostPlatform.system;

  yaziPkg = inputs.yazi.packages.${hostSystem}.default.override {
    _7zz = pkgs._7zz-rar;
  };

  yaziOpen = pkgs.writeShellScriptBin "yazi-open" ''
    set -efu

    target="''${1:-$HOME}"

    case "$target" in
      file://*)
        target="$(${lib.getExe pkgs.python3} -c 'import sys, urllib.parse; print(urllib.parse.unquote(urllib.parse.urlparse(sys.argv[1]).path))' "$target")"
        ;;
    esac

    if [ -f "$target" ]; then
      target="$(dirname "$target")"
    fi

    if [ ! -e "$target" ]; then
      target="$HOME"
    fi

    exec ${lib.getExe pkgs.ghostty} --title="Yazi" -e ${lib.getExe yaziPkg} "$target"
  '';

  fileManager1 = pkgs.writeShellScriptBin "yazi-filemanager1" ''
    exec ${pkgs.python3.withPackages (ps: [ ps.dbus-next ])}/bin/python ${pkgs.writeText "yazi-filemanager1.py" ''
      import asyncio
      import os
      import subprocess
      import urllib.parse

      from dbus_next.aio import MessageBus
      from dbus_next.constants import BusType
      from dbus_next.service import ServiceInterface, method

      YAZI_OPEN = ${builtins.toJSON (lib.getExe yaziOpen)}


      def uri_to_path(uri: str) -> str | None:
        parsed = urllib.parse.urlparse(uri)
        if parsed.scheme != "file":
          return None
        return urllib.parse.unquote(parsed.path)


      def open_paths(uris: list[str], reveal_items: bool = False) -> None:
        for uri in uris:
          path = uri_to_path(uri)
          if not path:
            continue

          if reveal_items and os.path.isfile(path):
            path = os.path.dirname(path)

          subprocess.Popen(
            [YAZI_OPEN, path],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
          )


      class FileManager1(ServiceInterface):
        def __init__(self) -> None:
          super().__init__("org.freedesktop.FileManager1")

        @method()
        def ShowFolders(self, uris: "as", startup_id: "s") -> "":
          open_paths(uris)

        @method()
        def ShowItems(self, uris: "as", startup_id: "s") -> "":
          open_paths(uris, reveal_items=True)

        @method()
        def ShowItemProperties(self, uris: "as", startup_id: "s") -> "":
          open_paths(uris, reveal_items=True)


      async def main() -> None:
        bus = await MessageBus(bus_type=BusType.SESSION).connect()
        bus.export("/org/freedesktop/FileManager1", FileManager1())
        await bus.request_name("org.freedesktop.FileManager1")
        await asyncio.Event().wait()

      asyncio.run(main())
    ''}
  '';
in {
  home.packages = with pkgs; [
    ( ouch.override { enableUnfree = true; } )
    yaziOpen
  ];

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    genericName = "File Manager";
    exec = "${lib.getExe yaziOpen} %U";
    terminal = false;
    mimeType = [ "inode/directory" ];
    categories = [ "System" "FileTools" "FileManager" ];
    startupNotify = false;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "yazi.desktop";
      "application/x-gnome-saved-search" = "yazi.desktop";
    };
  };

  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.FileManager1
    Exec=${lib.getExe fileManager1}
  '';

  wayland.windowManager.hyprland.settings.windowrule = [
    "match:class dragon-drop, move cursor_x-window_w/2 cursor_y-window_h/2"
  ];

  programs.yazi = {
    package = yaziPkg;
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        show_hidden = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
      plugin = {
        preloaders = [
          { url = "*.crdownload"; run = "noop"; }
        ];

        prepend_previewers = [
          { mime = "application/xz";            run = "ouch"; }
          { mime = "application/zip";           run = "ouch"; }
          { mime = "application/rar";           run = "ouch"; }
          { mime = "application/gzip";          run = "ouch"; }
          { mime = "application/7z-compressed"; run = "ouch"; }
        ];

        prepend_fetchers = [
          { group = "git"; url = "*"; run = "git"; }
        ];
      };
    };

    plugins = let
      yaziPlugin = name: pkgs.stdenvNoCC.mkDerivation {
        pname = "${name}.yazi";
        version = "unstable";
        src = inputs.yazi-plugins;

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r ${name}.yazi/* $out/
          rm -f $out/LICENSE
          cp LICENSE $out/LICENSE
          runHook postInstall
        '';
      };
    in with pkgs.yaziPlugins; {
      inherit
        chmod
        ouch
        mount
        toggle-pane
      ;

      full-border = {
        package = yaziPlugin "full-border";
        setup = true;
      };

      starship = {
        package = starship;
        setup = true;
      };

      git = {
        package = git;
        setup = true;
      };
    };

    initLua = ''
      Status:children_add(function()
        local h = cx.active.current.hovered
        if not h or ya.target_family() ~= "unix" then
          return ""
        end

        return ui.Line {
          ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
          ":",
          ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
          " ",
        }
      end, 500, Status.RIGHT)
    '';

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = "Y";
          run = ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list'';
          desc = "Copy files into system clipboard";
        }
        {
          on = ["c" "m"];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
        {
          on = ["M"];
          run = "plugin mount";
          desc = "Open mount menu";
        }
        {
          on = [ "<C-n>" ];
          run = "shell '${lib.getExe pkgs.dragon-drop} -x -A -i -T %s'";
        }
        {
          on = [ "g" "<S-d>" ];
          run = ''cd /mnt/D'';
          desc = "Goto D drive";
        }
      ];
    };
  };
}
