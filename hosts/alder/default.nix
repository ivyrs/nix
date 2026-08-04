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
      den.aspects.noctalia
      den.aspects.onepassword
      den.aspects.desktop
      den.aspects.music
      den.aspects.productivity
    ];

    nixos = {
      imports = [
        ./_hardware-configuration.nix
        inputs.nixos-apple-silicon.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        config.flake.modules.nixos.sops
        ({
          pkgs,
          lib,
          config,
          ...
        }: {
          hardware.asahi.enable = true;

          # peripheralFirmwareDirectory points outside this repo: firmware.cpio
          # is Apple's proprietary firmware (extraction itself is standard
          # practice, same as Linux distros pulling WiFi/RAID firmware off a
          # Windows OEM partition), and this repo's Codeberg remote is public —
          # committing it would redistribute it. Also needs setting explicitly
          # since the module's path-probing default doesn't evaluate reliably
          # from a flake built on another machine (e.g. aspen).
          hardware.asahi.extractPeripheralFirmware = true;
          hardware.asahi.peripheralFirmwareDirectory = /etc/nixos/asahi-firmware;
          # Asahi's U-Boot/m1n1 stack manages EFI vars, not Linux.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = false;

          networking.networkmanager.enable = true;
          networking.networkmanager.wifi.backend = "iwd";

          # SSH key + shell come from den.aspects.ivy.nixos (modules/users/ivy.nix);
          # see AGENTS.md/memory to retrieve them. Password overridden below:
          # alder's greetd login is typed at a physical keyboard, so it gets an
          # easier-to-type secret instead of the shared random per-host one.
          sops.secrets.ivy-password-hash-alder = {};
          users.users.ivy.hashedPasswordFile = lib.mkForce config.sops.secrets.ivy-password-hash-alder.path;

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
