{den, ...}: {
  den.aspects.niri.nixos = {
    pkgs,
    lib,
    ...
  }: {
    programs.niri.enable = true;

    environment.systemPackages = [
      pkgs.xwayland-satellite 
      pkgs.brightnessctl 
      pkgs.playerctl 
      pkgs.wl-clipboard
    ];

    services.udev.packages = [pkgs.brightnessctl];
    users.users.ivy.extraGroups = ["video"];

    services.udisks2.enable = true;

    services.displayManager.ly.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk];
      config = {
        common = {
          default = ["gtk"];
        };
        niri = {
          default = lib.mkForce ["gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
          "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
        };
      };
    };
  };

  den.aspects.niri.homeManager = {pkgs, ...}: {
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
    xdg.configFile."niri/ux.kdl".source = ./ux.kdl;
    xdg.configFile."niri/binds.kdl".source = ./binds.kdl;
    xdg.configFile."niri/settings.kdl".source = ./settings.kdl;

    services.udiskie.enable = true;

    # Used by binds.kdl to raise an already-open window instead of spawning
    # a duplicate instance (niri has no built-in "run or raise" action).
    home.packages = [
      (pkgs.writeShellApplication {
        name = "focus-or-spawn";
        runtimeInputs = [pkgs.jq pkgs.niri];
        text = ''
          app_id=$1
          shift

          id=$(niri msg -j windows | jq -r --arg app "$app_id" '[.[] | select(.app_id == $app)][0].id // empty')

          if [ -n "$id" ]; then
            exec niri msg action focus-window --id "$id"
          else
            exec "$@"
          fi
        '';
      })
    ];
  };
}
