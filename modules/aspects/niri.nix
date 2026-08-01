{
  # First Linux DE/WM aspect in this repo (aspen doesn't need one — macOS
  # has its own). Kept minimal for alder's initial bring-up; expand once
  # it's in daily use. programs.niri's own nixpkgs module already wires up
  # xdg-desktop-portal-gnome for screen sharing, so nothing extra needed here.
  den.aspects.niri.nixos = {pkgs, ...}: {
    programs.niri.enable = true;

    services.greetd = {
      enable = true;
      settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --cmd niri-session";
    };
  };
}
