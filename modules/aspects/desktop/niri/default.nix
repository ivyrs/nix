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

    environment.systemPackages = [
      pkgs.xwayland-satellite 
      pkgs.brightnessctl 
      pkgs.playerctl 
      pkgs.wl-clipboard
    ];

    services.udev.packages = [pkgs.brightnessctl];
    users.users.ivy.extraGroups = ["video"];

    services.udisks2.enable = true;

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

    services.udiskie.enable = true;
  };
}
