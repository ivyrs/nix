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
        config.flake.modules.nixos.sops-elm-services
        ({
          pkgs,
          config,
          ...
        }: {
          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.networkmanager.enable = true;

          # Password + SSH key are declarative (see modules/sops.nix); see AGENTS.md/memory for retrieving the password.
          users.users.ivy = {
            description = "ivy";
            packages = [];
            shell = pkgs.zsh;
            hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ aspen"
            ];
          };

          programs.zsh.enable = true;

          environment.systemPackages = with pkgs; [
            curl
            just
            git
            ghostty # terminfo for SSH sessions from a Ghostty client
            ethtool
          ];

          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = false; # key-only; the declarative password is for local console recovery, not SSH.
          };

          networking.firewall.enable = true;

          # Allows unattended remote deploys (`just deploy elm`) to activate over SSH without a password prompt.
          security.sudo.wheelNeedsPassword = false;

          system.stateVersion = "25.11"; # don't fuck with this
        })
      ];
    };
  };
}
