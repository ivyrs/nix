# Alder imports this profile; the local Lark input is pinned in flake.lock.
{
  config,
  inputs,
  pkgs,
  ...
}:
let
  larkPackage = inputs.lark.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ inputs.lark.homeManagerModules.default ];

  services.lark = {
    enable = true;
    package = larkPackage;
    # Keep the existing handwritten config.toml untouched for comparison/rollback.
    settingsPath = "lark/nix.toml";
    # Create this private runtime file separately. Never put its contents in Nix.
    environmentFile = "${config.xdg.configHome}/lark/environment";
    settings = {
      output = "default";
      plugin = [
        {
          name = "navidrome";
          enabled = true;
          exec = [ "${larkPackage}/bin/lark-source-navidrome" ];
          config = {
            url = "https://music.moose-amberjack.ts.net";
            username = "ivy";
            password_env = "NAVIDROME_PASSWORD";
          };
        }
        {
          name = "mpd";
          enabled = true;
          exec = [ "${larkPackage}/bin/lark-frontend-mpd" ];
          config = {
            host = "127.0.0.1";
            port = 6600;
          };
        }
      ];
    };
  };

  # Preserve the working, unmanaged rmpc config and all other music applications.
  home.packages = [ inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.rmpc ];
}
