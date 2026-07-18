# Nix daemon settings shared by every host, as a cross-class aspect: hosts
# pull it in via `den.aspects.<host>.includes` and get the variant matching
# their class. GC/optimise is darwin-only for now — elm predates it and
# adding it there would be a behaviour change.
{
  den.aspects.nix-settings = {
    darwin = { pkgs, ... }: {
      # Keep the system on Lix — nix-darwin would otherwise swap in upstream Nix.
      nix.package = pkgs.lix;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Weekly GC + store optimisation.
      nix.gc.automatic = true;
      nix.gc.interval = { Weekday = 0; Hour = 3; Minute = 0; };
      nix.gc.options = "--delete-older-than 30d";
      nix.optimise.automatic = true;

      nixpkgs.config.allowUnfree = true;
    };

    nixos = {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
    };
  };
}
