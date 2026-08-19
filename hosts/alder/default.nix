{
  den,
  inputs,
  ...
}: {
  den.hosts.aarch64-linux.alder.users.ivy = {};

  den.aspects.alder = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
      den.aspects.sops
      den.aspects.overlays
      den.aspects.i18n
      den.aspects.tailscale-client
      den.aspects.niri
      # den.aspects.mango # disabled for now
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
        ({
          pkgs,
          lib,
          config,
          ...
        }: {
          hardware.asahi.enable = true;

          # ccache for the Asahi kernel: it builds from source every time
          # (nixos-apple-silicon has no binary cache — see
          # https://github.com/NixOS/nixos-hardware/issues/854), and a
          # bump of the (followed) nixpkgs input alone forces a full
          # from-scratch rebuild even when the kernel source itself is
          # unchanged. `programs.ccache.packageNames` can't target it: the
          # top-level `linux-asahi` attr is a `linuxPackagesFor`-wrapped
          # set whose `.override` only takes `_kernelPatches`, not
          # `stdenv`, so the module's `super.${pn}.override { stdenv =
          # ...; }` would error. Wire it in manually instead: replicate the
          # module's ccacheWrapper overlay (points CCACHE_DIR at the
          # persistent cache dir instead of the sandbox's throwaway
          # $HOME/.ccache) and swap stdenv on the inner `.kernel`
          # derivation, which does accept it.
          programs.ccache.enable = true;
          nix.settings.extra-sandbox-paths = [config.programs.ccache.cacheDir];
          nixpkgs.overlays = [
            (final: prev: {
              ccacheWrapper = prev.ccacheWrapper.override {
                extraConfig = ''
                  export CCACHE_COMPRESS=1
                  export CCACHE_SLOPPINESS=random_seed
                  export CCACHE_DIR="${config.programs.ccache.cacheDir}"
                  export CCACHE_UMASK=007
                '';
              };
            })
          ];
          boot.kernelPackages = lib.mkForce (
            pkgs.linuxPackagesFor (
              (config.hardware.asahi.pkgs.linux-asahi.override {
                _kernelPatches = config.boot.kernelPatches;
              }).kernel.override {stdenv = pkgs.ccacheStdenv;}
            )
          );

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

          # Pull side: lets a reinstalled/rolled-back alder (or anything
          # else that ends up needing these aarch64-linux/asahi paths) fetch
          # from the same cache instead of rebuilding.
          nix.settings = {
            extra-substituters = ["https://ivyturner.cachix.org"];
            extra-trusted-public-keys = ["ivyturner.cachix.org-1:G+GeQA1oBRaM2FfsUJph4QH8bNlkpvEQmxt42YFO00o="];
          };

          # Push side: sends everything alder builds locally (the
          # ccache-built kernel included) to the same cache. Auth token is
          # stored as an EnvironmentFile (CACHIX_AUTH_TOKEN=...) since
          # that's the only non-interactive way to hand cachix a token; add
          # it via `sops secrets/secrets.yaml` (see AGENTS.md's Secrets
          # section).
          sops.secrets.cachix-auth-token-alder = {};
          systemd.services.cachix-watch-store = {
            description = "Push new /nix/store paths to the ivyturner Cachix cache";
            wantedBy = ["multi-user.target"];
            after = ["network-online.target"];
            wants = ["network-online.target"];
            serviceConfig = {
              ExecStart = "${pkgs.cachix}/bin/cachix watch-store ivyturner";
              EnvironmentFile = config.sops.secrets.cachix-auth-token-alder.path;
              Restart = "on-failure";
              RestartSec = "30s";
            };
          };

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
