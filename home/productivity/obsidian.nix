{ inputs, pkgs, ... }: {
  programs.obsidian = {
    enable = true;
    cli.enable = true;
  };

  home.packages = [ inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.handy ];
}
