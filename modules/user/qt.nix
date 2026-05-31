{ lib, ... }: {
  # Keep qtct/Kvantum for styling, but tell qtct to delegate standard file
  # dialogs to xdg-desktop-portal. This is what makes AyuGram/Telegram-like Qt
  # apps use the Yazi picker instead of Qt's built-in dialog.
  stylix.targets.qt.standardDialogs = "xdgdesktopportal";

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = lib.mkForce "xdgdesktopportal";
    TDESKTOP_USE_GTK_FILE_DIALOG = "1";
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };
}
