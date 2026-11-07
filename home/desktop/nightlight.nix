{ lib, pkgs, ... }:
let
  noctaliaSettings = builtins.fromTOML (builtins.readFile ./noctalia/noctalia.toml);
in
{
  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    temperature = {
      day = 6500;
      night = 4500;
    };
    settings = {
      general.adjustment-method = "wayland";
      wayland.output = "eDP-*";
    };
  };

  # Only one gamma controller can own an output at a time.
  programs.noctalia.settings = lib.mkForce (
    (pkgs.formats.toml { }).generate "noctalia-laptop.toml" (
      noctaliaSettings
      // {
        nightlight = noctaliaSettings.nightlight // {
          enabled = false;
        };
      }
    )
  );
}
