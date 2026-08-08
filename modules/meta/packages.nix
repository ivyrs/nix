{
  inputs,
  lib,
  ...
}: let
  systems = ["aarch64-linux" "x86_64-linux"];

  perSystemOutputs =
    lib.genAttrs systems
    (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      glance-agent = pkgs.callPackage ../../packages/glance-agent/default.nix {};
      nokkvi = pkgs.callPackage ../../packages/nokkvi/default.nix {};
      tsui = pkgs.callPackage ../../packages/tsui/default.nix {};
    });
in {
  flake.packages = perSystemOutputs;
}
