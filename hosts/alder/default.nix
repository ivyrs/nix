{
  config,
  den,
  inputs,
  ...
}: {
  den.hosts.aarch64-linux.alder.users.ivy = {};

  den.aspects.alder = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
      den.aspects.i18n
      den.aspects.tailscale-client
      den.aspects.niri
    ];

    nixos = {
      imports = [
        ./_hardware-configuration.nix
        inputs.nixos-apple-silicon.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.sops
        ({pkgs, ...}: {
          hardware.asahi.enable = true;

          # Peripheral firmware (WiFi/webcam/etc.) ships as vendorfw/firmware.cpio
          # on the ESP, put there by the Asahi installer — it doesn't exist until
          # the physical install happens. Disabled for now; once installed, point
          # peripheralFirmwareDirectory at a path *outside* this repo (e.g.
          # /etc/nixos/asahi-firmware on alder itself) — this repo's Codeberg
          # remote is public, and firmware.cpio is Apple's proprietary binary
          # firmware extracted from this machine's own macOS install; committing
          # it here would redistribute it to anyone who clones the repo, unlike
          # the extraction itself which is local-only and standard practice (same
          # category as Linux distros pulling WiFi/RAID firmware off a Windows
          # OEM partition). The module's own path-probing default doesn't
          # evaluate reliably from a flake built on another machine (e.g. aspen)
          # either way, so this still needs to be set explicitly.
          hardware.asahi.extractPeripheralFirmware = false;

          # Asahi's U-Boot/m1n1 stack manages EFI vars, not Linux.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = false;

          networking.networkmanager.enable = true;
          networking.networkmanager.wifi.backend = "iwd";

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
            settings.PasswordAuthentication = false; # key-only; the declarative password is for console recovery, not SSH.
          };

          networking.firewall.enable = true;

          # Allows unattended remote deploys (`just deploy alder`) to activate over SSH without a password prompt.
          security.sudo.wheelNeedsPassword = false;

          system.stateVersion = "25.11";
        })
      ];
    };
  };
}
