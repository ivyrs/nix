{ pkgs, ... }:
{
  programs.niri.enable = true;
  # Authentication for the Home Manager swaylock configuration.
  security.pam.services.swaylock = { };
  # File selection uses GTK rather than GNOME's Nautilus-backed portal.
  programs.niri.useNautilus = false;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
