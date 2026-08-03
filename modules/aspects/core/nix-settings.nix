{
  den.aspects.nix-settings = {
    darwin = {pkgs, ...}: {
      # Keep the system on Lix — nix-darwin would otherwise swap in upstream Nix.
      nix.package = pkgs.lix;
      nix.settings.experimental-features = ["nix-command" "flakes"];

      # Weekly GC + store optimisation.
      nix.gc.automatic = true;
      nix.gc.interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      nix.gc.options = "--delete-older-than 30d";
      nix.optimise.automatic = true;

      nixpkgs.config.allowUnfree = true;
    };

    nixos = {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      # Weekly GC + store optimisation. NixOS takes a systemd calendar
      # string here, not darwin's launchd interval attrset.
      nix.gc.automatic = true;
      nix.gc.dates = "Sun 03:00";
      nix.gc.options = "--delete-older-than 30d";
      nix.optimise.automatic = true;

      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };
  };
}
