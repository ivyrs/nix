{
  config,
  den,
  inputs,
  ...
}: {
  den.aspects.elm = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
    ];

    nixos = {
      imports = [
        ./_hardware-configuration.nix
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.i18n
        config.flake.modules.nixos.tailscale-server
        config.flake.modules.nixos.syncthing
        config.flake.modules.nixos.glance
        config.flake.modules.nixos.miniflux
        config.flake.modules.nixos.pocket-id
        # config.flake.modules.nixos.vikunja # disabled 2026-07-21, pending pocket-id redirect URI fix (see project_forgejo_elm memory)
        config.flake.modules.nixos.vaultwarden
        config.flake.modules.nixos.nextcloud
        config.flake.modules.nixos.gotosocial
        config.flake.modules.nixos.forgejo
        config.flake.modules.nixos.sops
        ({pkgs, ...}: {
          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.networkmanager.enable = true;

          # Define a user account. Don't forget to set a password with 'passwd'.
          users.users.ivy = {
            description = "ivy";
            packages = [];
            shell = pkgs.zsh;
          };

          programs.zsh.enable = true;

          environment.systemPackages = with pkgs; [
            curl
            just
            git
            ghostty # terminfo for SSH sessions from a Ghostty client
            ethtool
          ];

          services.openssh.enable = true;

          networking.firewall.enable = true;

          # Allows unattended remote deploys (`just deploy elm`) to activate over SSH without a password prompt.
          security.sudo.wheelNeedsPassword = false;

          system.stateVersion = "25.11"; # don't fuck with this
        })
      ];
    };
  };
}
