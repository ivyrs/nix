{
  den.aspects.nix-settings = {
    darwin = {pkgs, ...}: {
      # Keep the system on Lix — nix-darwin would otherwise swap in upstream Nix.
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

    nixos = {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      # Weekly store optimisation. GC is nh's job here (below) —
      # nix.gc.automatic and programs.nh.clean both doing it is a
      # conflict nixpkgs itself warns about, so nh is the sole owner.
      nix.optimise.automatic = true;

      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
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
