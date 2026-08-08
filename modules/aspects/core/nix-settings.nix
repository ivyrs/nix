{
  den.aspects.nix-settings = {
    darwin = {pkgs, ...}: {
      # nix for lesbians
      nix.package = pkgs.lix;
      nix.settings.experimental-features = ["nix-command" "flakes"];

      # Weekly store optimisation. GC itself is nh's job on NixOS (see
      # below); nix-darwin has no programs.nh module, so this host still
      # cleans up via plain nix.gc.
      nix.gc.automatic = true;
      nix.gc.interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      nix.gc.options = "--delete-older-than 30d";
      nix.optimise.automatic = true;

      nixpkgs.config.allowUnfree = true;

      # nh has no OS-level module on darwin (unlike NixOS); set NH_FLAKE as
      # a plain env var so ad-hoc `nh darwin switch` (outside the justfile,
      # which already passes the flake path explicitly) defaults here.
      environment.variables.NH_FLAKE = "/home/ivy/nix";
    };

    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [
        (final: prev: {
          inherit
            (prev.lixPackageSets.stable)
            nixpkgs-review
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        })
      ];

      # nix for lesbians
      nix.package = pkgs.lixPackageSets.stable.lix;

      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      # Weekly store optimisation. GC is nh's job (below)
      nix.optimise.automatic = true;

      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
        # Every NixOS host already gives wheel passwordless sudo
        # (security.sudo.wheelNeedsPassword = false), so trusting @wheel
        # here doesn't grant anything ivy couldn't already reach via `sudo
        # nix ...` — it just means plain `nix build`/`nixos-rebuild` can
        # use restricted settings (e.g. extra-sandbox-paths) directly.
        trusted-users = ["root" "@wheel"];
      };

      # den.aspects.cli-tools already installs nh via home-manager (shared
      # with darwin, which has no OS-level programs.nh module) — enabling
      # this too is harmless (dedup'd package), and gets us NH_FLAKE plus
      # the weekly `nh clean all` GC timer.
      programs.nh = {
        enable = true;
        flake = "/home/ivy/nix";
        clean = {
          enable = true;
          dates = "Sun 03:00";
        };
      };
    };
  };
}
