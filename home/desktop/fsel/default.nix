{ pkgs, ... }:
{
  home.packages = [ (pkgs.callPackage ../../../pkgs/fsel.nix { }) ];

  xdg.configFile."fsel/config.toml".text = ''
    terminal_launcher = "ghostty --gtk-single-instance=false --class=rs.ivy.tui -e"
    title_panel_height_percent = 0

    # strip the chrome
    show_main_border = false
    show_items_border = false
    show_input_border = false
    show_panel_titles = false
    show_input_count = false
    show_pin_icons = false

    # otter-style selection: marker + no filled bar
    show_selection_marker = true
    selection_marker = "▌ "
    input_panel_style = "classic"
    input_panel_height = 2

    [app_launcher]
    icon_mode = "none"
    filter_actions = true
    auto_hide_duplicates = true

    [panels]
    input_position = "bottom"
  '';
}
