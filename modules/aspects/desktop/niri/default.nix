{self, inputs, den, ...}: {
  den.aspects.niri.nixos = {pkgs, lib, ...}: {
    programs.niri.enable = true;

    # niri (25.08+) automatically spawns xwayland-satellite on demand when an
    # X11 client connects and exports $DISPLAY — no KDL config needed, it
    # just needs the binary on PATH. Without this, X11-only apps (e.g. Steam,
    # which still uses an X11 bootstrapper UI) fail with "Could not open
    # connection to X".
    environment.systemPackages = [pkgs.xwayland-satellite pkgs.brightnessctl];

    # brightnessctl's own udev rules chgrp/chmod /sys/class/backlight/*/brightness
    # to group "video" (g+w) so the XF86MonBrightnessUp/Down binds in config.kdl
    # can run it unprivileged. Without this the rules package is never
    # installed, so the sysfs node stays root-owned and the binds fail silently.
    services.udev.packages = [pkgs.brightnessctl];
    users.users.ivy.extraGroups = ["video"];

    services.greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
    };

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

  den.aspects.niri.homeManager = {
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
    xdg.configFile."niri/ux.kdl".source = ./ux.kdl;
    xdg.configFile."niri/binds.kdl".source = ./binds.kdl;
    xdg.configFile."niri/settings.kdl".source = ./settings.kdl;
  };
}
