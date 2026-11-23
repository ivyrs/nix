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
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  home.packages = [
    inputs.albedo.packages.${pkgs.stdenv.hostPlatform.system}.default
    # unstable.opencode
    # (unstable.callPackage ../../pkgs/t3-code-nightly.nix { })
    # unstable.claude-code
    # unstable.codex
    # (pkgs.callPackage ../../pkgs/polytoken.nix { })
  ];

  programs.hermes-agent = {
    enable = true;
    desktop.enable = true;
  };
}
