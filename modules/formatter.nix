{inputs, ...}: {
  flake.formatter =
    inputs.nixpkgs.lib.genAttrs
    ["aarch64-darwin" "x86_64-linux" "aarch64-linux"]
    (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
}
