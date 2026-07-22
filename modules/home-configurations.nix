# Standalone home-manager outputs — the home environment for machines this
# flake does NOT manage (no nix-darwin/NixOS wiring, just the user profile).
# On such a machine, with nix installed:
#
#   nix run home-manager -- switch --flake github:ivyturner/nix#ivy@x86_64-linux
#
# The local account must match the entry's username; add a one-line entry
# below for a different account name.
{
  inputs,
  config,
  lib,
  ...
}: let
  mkHome = username: system:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        config.flake.modules.homeManager.base
        {
          home.username = username;
          home.homeDirectory =
            if lib.hasSuffix "darwin" system
            then "/Users/${username}"
            else "/home/${username}";
          # Standalone homes don't get den.default's stateVersion; keep in step
          # with modules/den.nix.
          home.stateVersion = "25.11";
        }
      ];
    };

  systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

  forAllSystems = username:
    lib.listToAttrs (map
      (system: {
        name = "${username}@${system}";
        value = mkHome username system;
      })
      systems);
in {
  flake.homeConfigurations = forAllSystems "ivy";
}
