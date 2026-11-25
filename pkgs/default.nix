{ inputs, pkgs }:

let
  neovim =
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [
        ../home/dev/neovim/config/core.nix
        ../home/dev/neovim/config/languages.nix
      ];
    }).neovim;
in
{
  default = neovim;
  inherit neovim;

  neovim-core =
    (inputs.nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [ ../home/dev/neovim/config/core.nix ];
    }).neovim;
}
// pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  fsel = pkgs.callPackage ./fsel.nix { };
  cclip = pkgs.callPackage ./cclip.nix { };
  nmrs-tui = pkgs.callPackage ./nmrs-tui.nix {
    inherit (inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}) rustPlatform;
  };
}
