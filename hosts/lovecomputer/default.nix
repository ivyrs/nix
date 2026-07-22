{
  config,
  den,
  inputs,
  ...
}: {
  den.aspects.lovecomputer = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
    ];

    nixos = {
      imports = [
        ./_hardware-configuration.nix
        ./_disko.nix
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.i18n
        config.flake.modules.nixos.tailscale-server
        config.flake.modules.nixos.lovecomputer-caddy
        config.flake.modules.nixos.glance-agent
        config.flake.modules.nixos.sops
        ({
          pkgs,
          config,
          ...
        }: {
          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # Hetzner's DHCP hands out the public v4 /32 + a point-to-point
          # route; IPv6 comes via SLAAC. No static config needed.
          networking.useDHCP = true;

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
          ];

          services.openssh = {
            enable = true;
            openFirewall = false; # SSH is tailnet-only; see allowedTCPPorts below.
            settings.PasswordAuthentication = false; # key-only; the declarative password is for console/VNC recovery, not SSH.
          };

          networking.firewall.enable = true;
          # lovecomputer is a public edge — it terminates real internet
          # traffic for Caddy, like houseplants, unlike every other
          # host/service in this repo which only ever opens ports on
          # tailscale0.
          networking.firewall.allowedTCPPorts = [80 443];
          networking.firewall.interfaces."tailscale0".allowedTCPPorts = [22];

          # Allows unattended remote deploys (`just deploy lovecomputer`) to activate over SSH without a password prompt.
          security.sudo.wheelNeedsPassword = false;

          system.stateVersion = "25.11"; # don't fuck with this
        })
      ];
    };
  };
}
