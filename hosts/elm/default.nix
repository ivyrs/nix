{ config, ... }:
{
  flake.modules.nixos.elm = {
    imports = [
      ./_hardware-configuration.nix
      config.flake.modules.nixos.i18n
      config.flake.modules.nixos.syncthing
      config.flake.modules.nixos.glance
      config.flake.modules.nixos.miniflux
      config.flake.modules.nixos.pocket-id
      config.flake.modules.nixos.vikunja
      config.flake.modules.nixos.vaultwarden
      config.flake.modules.nixos.sops
      ({ pkgs, ... }: {
        # nix settings
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # Bootloader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.hostName = "elm";
        networking.networkmanager.enable = true;

        # Define a user account. Don't forget to set a password with 'passwd'.
        users.users.ivy = {
          isNormalUser = true;
          description = "ivy";
          extraGroups = [ "networkmanager" "wheel" ];
          packages = [ ];
          shell = pkgs.zsh;
        };

        programs.zsh.enable = true;

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;

        # List packages installed in system profile. To search, run:
        # $ nix search wget
        environment.systemPackages = with pkgs; [
          curl
          just
          git
          ghostty
          ethtool
        ];

        services.openssh.enable = true;

        services.tailscale = {
          enable = true;
          useRoutingFeatures = "server";
          permitCertUid = "caddy";
        };

        networking.firewall.enable = true;

        # Allows unattended remote deploys (`just deploy elm`) to activate over SSH without a password prompt.
        security.sudo.wheelNeedsPassword = false;

        system.stateVersion = "25.11"; # don't fuck with this
      })
    ];
  };
}
