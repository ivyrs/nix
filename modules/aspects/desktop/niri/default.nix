{
  self,
  inputs,
  den,
  ...
}: {
  den.aspects.niri.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.noctalia-greeter.nixosModules.default];

    programs.niri.enable = true;

    # niri (25.08+) auto-spawns xwayland-satellite on demand when an X11
    # client connects — no KDL config needed, just the binary on PATH.
    # Without it, X11-only apps (e.g. Steam's X11 bootstrapper UI) fail with
    # "Could not open connection to X". playerctl backs the XF86Audio*
    # media-key binds in binds.kdl (MPRIS control) — same PATH reasoning.
    environment.systemPackages = [pkgs.xwayland-satellite pkgs.brightnessctl pkgs.playerctl];

    # brightnessctl's udev rules chgrp/chmod /sys/class/backlight/*/brightness
    # to group "video" so config.kdl's XF86MonBrightnessUp/Down binds can run
    # it unprivileged. Without this the sysfs node stays root-owned and the
    # binds fail silently.
    services.udev.packages = [pkgs.brightnessctl];
    users.users.ivy.extraGroups = ["video"];

    # Noctalia's own greeter, styled to match the desktop session (replaces
    # tuigreet). See https://docs.noctalia.dev/v5/greeter/
    programs.noctalia-greeter = {
      enable = true;
      settings.session.default = "niri";
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
