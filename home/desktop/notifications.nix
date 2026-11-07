{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "top";
      font = "sans-serif 11";
      width = 360;
      margin = 16;
      padding = 14;
      border-size = 1;
      border-radius = 10;
      background-color = "#282828f2";
      text-color = "#ebdbb2";
      border-color = "#665c54";
      progress-color = "over #504945";
      max-icon-size = 48;
      default-timeout = 7000;
      max-visible = 4;
      max-history = 50;
      on-button-left = "invoke-default-action";
      on-button-right = "dismiss";
      "urgency=critical" = {
        border-color = "#fb4934";
        default-timeout = 0;
      };
      "mode=do-not-disturb".invisible = true;
    };
    # Mako matches sender names exactly, unlike Noctalia's substring filter.
    extraConfig =
      lib.concatMapStringsSep "\n"
        (app: ''
          [app-name="${app}"]
          history=0
          ignore-timeout=1
          default-timeout=7000
        '')
        [
          "claude"
          "Claude"
          "Claude Code"
        ];
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      PartOf = [ "niri.service" ];
      After = [
        "niri.service"
        "noctalia.service"
      ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${config.services.mako.package}/bin/mako";
      ExecReload = "${config.services.mako.package}/bin/makoctl reload";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "niri.service" ];
  };

  home.packages = [ pkgs.libnotify ];
}
