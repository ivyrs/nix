# Cross-platform productivity apps: nixpkgs package on Linux (alder),
# homebrew cask on darwin (aspen) — nix-darwin has no first-class Electron-app
# packaging story. Kept as one aspect per app rather than split across
# desktop/default.nix and mac/homebrew.nix, so each pair stays tied together.
{
  den.aspects.productivity.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.obsidian pkgs.calibre];
  };

  den.aspects.productivity.darwin.homebrew.casks = ["obsidian" "calibre"];
}
