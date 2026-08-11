{
  config,
  den,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.elm.users.ivy = {};

  # elm used to pin to nixpkgs-stable/home-manager-stable to match its NixOS
  # release; now tracks unstable like every other host (see README's "Inputs
  # of note").
  den.hosts.x86_64-linux.elm.instantiate = inputs.nixpkgs.lib.nixosSystem;
  den.hosts.x86_64-linux.elm.home-manager.module = inputs.home-manager.nixosModules.home-manager;

  den.aspects.elm = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
      den.aspects.i18n
      den.aspects.tailscale-server
      den.aspects.syncthing
      den.aspects.glance
      den.aspects.miniflux
      den.aspects.pocket-id
      den.aspects.vaultwarden
      den.aspects.nextcloud
      den.aspects.gotosocial
      den.aspects.forgejo
      den.aspects.multi-scrobbler
      den.aspects.ergo
      den.aspects.soju
    ];

    nixos = {
      imports = [
        ./_hardware-configuration.nix
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.sops
        config.flake.modules.nixos.sops-elm-services
        ({pkgs, ...}: {
          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          networking.networkmanager.enable = true;

          # Password + SSH key + shell are declarative via the shared
          # den.aspects.ivy.nixos (modules/users/ivy.nix); see AGENTS.md/memory
          # for retrieving the password.

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

          programs.nix-ld.enable = true;

          networking.firewall.enable = true;

          # Allows unattended remote deploys (`just deploy elm`) to activate over SSH without a password prompt.
          security.sudo.wheelNeedsPassword = false;

          system.stateVersion = "25.11"; # don't fuck with this
        })
      ];
    };
  };
}
