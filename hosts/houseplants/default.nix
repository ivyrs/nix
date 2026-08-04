{
  config,
  den,
  inputs,
  ...
}: {
  den.hosts.aarch64-linux.houseplants.users.ivy = {};

  den.aspects.houseplants = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
      den.aspects.i18n
      den.aspects.tailscale-server
      den.aspects.caddy
      den.aspects.glance-agent
    ];

    nixos = {
      imports = [
        ./_hardware-configuration.nix
        ./_disko.nix
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.sops
        ({pkgs, ...}: {
          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # Hetzner's DHCP hands out the public v4 /32 + a point-to-point
          # route; IPv6 comes via SLAAC. No static config needed.
          networking.useDHCP = true;

          # Password + SSH key + shell are declarative via the shared
          # den.aspects.ivy.nixos (modules/users/ivy.nix); see AGENTS.md/memory
          # for retrieving the password.

          environment.systemPackages = with pkgs; [
            curl
            just
            git
          ];

          services.openssh = {
            enable = true;
            openFirewall = false; # SSH is tailnet-only, reachable via Tailscale's own ts-input chain regardless of NixOS's firewall.
            settings.PasswordAuthentication = false; # key-only; the declarative password is for console/VNC recovery, not SSH.
          };

          networking.firewall.enable = true;
          # houseplants is the public edge — it terminates real internet
          # traffic for Caddy, unlike every other host/service in this repo
          # which only ever sits behind the tailnet.
          networking.firewall.allowedTCPPorts = [80 443];

          # Allows unattended remote deploys (`just deploy houseplants`) to activate over SSH without a password prompt.
          security.sudo.wheelNeedsPassword = false;

          system.stateVersion = "25.11"; # don't fuck with this
        })
      ];
    };
  };
}
