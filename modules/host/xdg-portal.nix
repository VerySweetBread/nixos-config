{ pkgs, inputs, ... }:

{
  # Важно: портал должен быть собран под тот же Hyprland, что и сам Hyprland
  # (есть отдельная опция именно для этого).
  programs.hyprland = {
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;

    # Делает так, что xdg-open идёт через портал (часто полезно для sandbox/FHS/wrappers).
    # Опция есть в NixOS как xdg.portal.xdgOpenUsePortal :contentReference[oaicite:2]{index=2}
    xdgOpenUsePortal = true;

    # Два бэкенда: Hyprland (композитор-специфичное) + GTK (интеграция/диалоги/OpenURI)
    extraPortals = [
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];

    # Роутинг интерфейсов по portals.conf(5):
    # xdg-desktop-portal выбирает конфиг по XDG_CURRENT_DESKTOP (с lower-case) :contentReference[oaicite:3]{index=3}
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot"  = [ "hyprland" ];
        "org.freedesktop.impl.portal.GlobalShortcuts" = [ "hyprland" ];
      };

      # Если XDG_CURRENT_DESKTOP=Hyprland присутствует — предпочитаем Hyprland,
      # но оставляем gtk как fallback для интерфейсов, которых нет у hyprland-портала.
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };
}