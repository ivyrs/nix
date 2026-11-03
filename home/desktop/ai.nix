{
  pkgs,
  inputs,
  config,
  hermesEnvFile,
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
    unstable.opencode
    (unstable.callPackage ../../pkgs/t3-code-nightly.nix { })
    unstable.claude-code
    unstable.codex
    inputs.albedo.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.callPackage ../../pkgs/polytoken.nix { })
  ];

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;
    backend.mode = "dashboard"; # + the browser dashboard on 127.0.0.1:9119
    backend.port = 9119;
    settings.model = {
      provider = "openai-codex";
      default = "gpt-6-sol";
    };
    environmentFiles = [ hermesEnvFile ];
  };
  programs.hermes-agent.enable = true;
}
