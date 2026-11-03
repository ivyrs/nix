{
  pkgs,
  inputs,
  ...
}:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    unstable.opencode
    (unstable.callPackage ../../pkgs/t3-code-nightly.nix { })
    unstable.claude-code
    unstable.codex
    inputs.albedo.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.callPackage ../../pkgs/polytoken.nix { })
  ];
}
