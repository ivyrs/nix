{
  inputs,
  metadata,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    inputs.jovian.nixosModules.default

    ../../../modules/system/nix
    ../../../modules/system/nix/nixos.nix
    ../../../modules/system/locale.nix
    ../../../modules/system/fonts.nix
    ../../../modules/users/ivy.nix
    ../../../modules/services/tailscale.nix
  ];

  networking = {
    hostName = metadata.hosts.willow.name;
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Jovian handles both LCD and OLED (Galileo): kernel, firmware, controls,
  # graphics, fan control and the Deck-specific PipeWire configuration.
  jovian = {
    devices.steamdeck.enable = true;
    steam = {
      enable = true;
      autoStart = true;
      user = metadata.user.username;
      desktopSession = "plasma";
    };
  };

  # Jovian owns the display manager/autologin. Do not import ly or the
  # workstation's Niri/audio/portal profile alongside it.
  services.desktopManager.plasma6.enable = true;
  programs.steam.enable = true; # Also provide Steam in desktop mode.
  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.tailscale.extraSetFlags = [ "--operator=${metadata.user.username}" ];

  services.upower.enable = true;
  services.udisks2.enable = true;
  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    kdePackages.konsole
  ];

  # Assumes a UEFI installation with an ESP mounted at /boot. Review for
  # dual boot; this draft deliberately does not partition or format disks.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Set ivy's password with nixos-install (see README); no shared bootstrap
  # password or passwordless sudo is enabled here. Tailscale sign-in is manual.
  system.stateVersion = "26.05";
}
