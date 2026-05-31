{ lib, ... }: {
  environment.variables = {
    EDITOR = "hx";
    RANGER_LOAD_DEFAULT_RC = "FALSE";
    # GTK/Electron apps do not consistently use the portal picker unless this
    # variable is present in the graphical session environment.
    GTK_USE_PORTAL = "1";

    # Qt/Telegram-like apps otherwise keep using their own picker. This makes
    # them ask xdg-desktop-portal for file/folder selection.
    QT_QPA_PLATFORMTHEME = lib.mkForce "xdgdesktopportal";
    TDESKTOP_USE_GTK_FILE_DIALOG = "1";

  };
}
