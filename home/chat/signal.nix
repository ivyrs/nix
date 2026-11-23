{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.signal-desktop
  ];
}
