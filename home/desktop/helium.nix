{ inputs, pkgs, ... }:

let
  # The community flake currently has the amd64 checksum on its arm64
  # source. Keep the package implementation there, but correct the artifact
  # checksum per architecture until that upstream issue is fixed.
  helium =
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.helium.overrideAttrs
      (old: {
        src = pkgs.fetchurl {
          url = "https://github.com/imputnet/helium-linux/releases/download/${old.version}/helium-bin_${old.version}-1_${
            {
              aarch64-linux = "arm64";
              x86_64-linux = "amd64";
            }
            .${pkgs.stdenv.hostPlatform.system}
          }.deb";
          hash =
            {
              aarch64-linux = "sha256-pJUSdkdrNLgDMCqnEPUxdpS6MJjeCgG2ztHON4DS9qQ=";
              x86_64-linux = "sha256-DmdZY9vhydvUNBV8iucNVSQofDsMvJa4W/eIVm7GBVE=";
            }
            .${pkgs.stdenv.hostPlatform.system};
        };
      });
in
{
  imports = [ inputs.helium-browser.homeModules.default ];

  programs.helium = {
    enable = true;
    package = helium;
  };
}
