{ pkgs, ... }:
let
  fsel = pkgs.callPackage ../../../pkgs/fsel.nix { };
  cclip = pkgs.callPackage ../../../pkgs/cclip.nix { };
in
{
  home.packages = [
    fsel
    cclip
    (pkgs.writeShellApplication {
      name = "fsel-clipboard";
      runtimeInputs = [
        pkgs.ghostty
        pkgs.wl-clipboard
        fsel
        cclip
      ];
      # Override the app launcher's hidden info panel for clipboard previews.
      text = ''
        exec ghostty --gtk-single-instance=false --class=rs.ivy.launcher -e \
          fsel --cclip --replace --info-size 40
      '';
    })
  ];

  systemd.user.services.cclip = {
    Unit = {
      Description = "Clipboard history for fsel";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      # Prefer image data over HTML, and plain text over other text formats.
      # Keep the default secret-data exclusion and do not watch primary selection.
      ExecStart = "${cclip}/bin/cclipd -c 1000 -t image/png -t image/* -t text/plain;charset=utf-8 -t text/plain -t text/*";
      Restart = "on-failure";
      RestartSec = 2;
      UMask = "0077";
    };
    # Home Manager starts new units wanted by active targets on a switch.
    # niri.service is already running and is not a target.
    Install.WantedBy = [ "graphical-session.target" ];
  };

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
