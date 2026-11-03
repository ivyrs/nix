{
  metadata,
  ...
}:

{
  imports = [
    ./hardware.nix

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/nix-ld.nix

    ../../../modules/users/ivy.nix

    ../../../modules/services/ssh.nix
    ../../../modules/services/tailscale.nix
    ../../../modules/services/ly.nix

    ../../../modules/desktop/niri.nix
    ../../../modules/desktop/portals.nix
    ../../../modules/desktop/audio.nix
    ../../../modules/desktop/theme.nix

    ../../../modules/system/fonts.nix
    ../../../modules/system/locale.nix

    ../../../modules/system/home-manager.nix
  ];

  home-manager.users.${metadata.user.username}.imports = [
    ./home.nix
    ../../../home
  ];

  networking = {
    hostName = metadata.hosts.maple.name;

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    firewall.enable = true;
  };

  services.tailscale.extraSetFlags = [ "--operator=ivy" ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  zramSwap.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics.enable = true; # provides /run/opengl-driver (Mesa)

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "26.05";

  # TODO: bootstrap-only, matches no sops secret yet. Run `passwd` after
  # first boot, then switch to a sops hashedPasswordFile once maple has
  # an age key (see alder's setup for the pattern).
  users.users.${metadata.user.username}.initialPassword = "changeme";
}
