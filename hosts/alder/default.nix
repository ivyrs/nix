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
      den.aspects.gaming
      den.aspects.onepassword
      den.aspects.fonts
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

          # Peripheral firmware (WiFi/webcam/etc.) ships as vendorfw/firmware.cpio
          # on the ESP, put there by the Asahi installer. peripheralFirmwareDirectory
          # points at a path *outside* this repo (/etc/nixos/asahi-firmware on
          # alder itself) — this repo's Codeberg remote is public, and
          # firmware.cpio is Apple's proprietary binary firmware extracted from
          # this machine's own macOS install; committing it here would
          # redistribute it to anyone who clones the repo, unlike the
          # extraction itself which is local-only and standard practice (same
          # category as Linux distros pulling WiFi/RAID firmware off a Windows
          # OEM partition). The module's own path-probing default doesn't
          # evaluate reliably from a flake built on another machine (e.g. aspen)
          # either way, so this still needs to be set explicitly.
          hardware.asahi.extractPeripheralFirmware = true;
          hardware.asahi.peripheralFirmwareDirectory = /etc/nixos/asahi-firmware;
          # Asahi's U-Boot/m1n1 stack manages EFI vars, not Linux.
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = false;

          networking.networkmanager.enable = true;
          networking.networkmanager.wifi.backend = "iwd";

          # SSH key + shell are declarative via the shared den.aspects.ivy.nixos
          # (modules/users/ivy.nix); see AGENTS.md/memory for retrieving them.
          # Password is overridden below: unlike the other NixOS hosts (SSH-key-only,
          # password is console-recovery-only), alder's greetd login means someone
          # actually types this at a physical keyboard, so it gets its own
          # easier-to-type secret instead of the shared random one.
          sops.secrets.ivy-password-hash-alder = {};
          users.users.ivy.hashedPasswordFile = lib.mkForce config.sops.secrets.ivy-password-hash-alder.path;

          environment.systemPackages = with pkgs; [
            curl
            just
            git
            ghostty
            vesktop
            obsidian
            calibre
            keymapp
            firefox
            feishin
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
