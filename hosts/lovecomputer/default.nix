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
        config.flake.modules.nixos.i18n
        config.flake.modules.nixos.tailscale-server
        config.flake.modules.nixos.lovecomputer-caddy
        ({pkgs, ...}: {
          # Bootloader.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # Hetzner's DHCP hands out the public v4 /32 + a point-to-point
          # route; IPv6 comes via SLAAC. No static config needed.
          networking.useDHCP = true;

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
          ];

          services.openssh = {
            enable = true;
            openFirewall = false; # SSH is tailnet-only; see allowedTCPPorts below.
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
