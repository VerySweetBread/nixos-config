{ config, pkgs, ... }: let
  icon = pkgs.fetchurl {
    url = "https://cloud.codrs.ru/pub/nixos-chan.webp?raw";
    name = "nixos-chan.webp";
    sha256 = "sha256-0majB9ljjMdZwvOijEgWdFKxWLje5tHgXHBJUWZfHfY=";
  };
in {
  home.packages = [ pkgs.fastfetch ];
  xdg.configFile."neofetch/config.conf".text = ''
print_info() {
    info title
    info underline

    prin "Hardware"
    info "-  Host" model
    info "-  Resolution" resolution
    info "-  CPU" cpu
    info "-  GPU" gpu gpu_driver
    info "-  Memory" memory
    info "-  Disk" disk
    info "-  Battery" battery

    echo
    prin "Software"

    info "-  OS" distro kernel
    # info "-  Uptime" uptime
    info "-  Packages" packages
    info "-  Shell" shell
    prin "-  Prompt" "Starship"
    info "-  Terminal" term
    info "-  DE" de
    info "-  WM" wm

    echo
    prin "Style"
    info "-  WM Theme" wm_theme
    info "-  Theme" theme
    prin "-  Base16 Theme" "${baseNameOf config.stylix.base16Scheme}"
    info "-  Icons" icons
    info "-  Terminal Font" term_font
    info "-  Font" font

    # info "-  Song" song
    [[ "$player" ]] && prin "-  Music Player" "$player"
    # info "-  Local IP" local_ip
    # info "-  Public IP" public_ip
    # info "-  Users" users
    info "-  Locale" locale  # This only works on glibc systems.

    info cols
}

title_fqdn="on"
kernel_shorthand="on"
distro_shorthand="on"
os_arch="on"
uptime_shorthand="on"
memory_percent="off"
memory_unit="mib"
package_managers="on"
shell_path="off"
shell_version="on"
speed_type="bios_limit"
speed_shorthand="on"
cpu_brand="on"
cpu_speed="on"
cpu_cores="logical"
cpu_temp="off"
gpu_brand="on"
gpu_type="all"
refresh_rate="on"
gtk_shorthand="off"
gtk2="on"
gtk3="on"
public_ip_host="http://ident.me"
local_ip_interface=('auto')
de_version="on"
disk_show=('/' '/mnt/D')
disk_subtitle="mount"
disk_percent="on"
music_player="auto"
song_format="%artist% - %album% - %title%"
song_shorthand="off"
mpc_args=()
colors=(distro)
bold="on"
underline_enabled="on"
underline_char="-"
separator=":"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
col_offset="auto"
bar_char_elapsed="="
bar_char_total="."
bar_border="on"
bar_length=15
bar_color_elapsed="distro"
bar_color_total="distro"
memory_display="infobar"
battery_display="off"
disk_display="infobar"
image_backend="kitty"
image_source=${icon}
ascii_distro="auto"
ascii_colors=(distro)
ascii_bold="on"
image_loop="off"
thumbnail_dir="${config.xdg.cacheHome}/thumbnails/neofetch"
crop_mode="normal"
crop_offset="center"
image_size="auto"
catimg_size="2"
gap=3
yoffset=0
xoffset=0
background_color=
stdout="off"
'';
}
