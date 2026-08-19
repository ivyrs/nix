{inputs, ...}: let
  unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config = prev.config;
    };
  };

  apps = final: prev: {
    devenv = final.unstable.devenv;
    discord = final.unstable.discord;
    zapp = final.unstable.zapp;
  };
in {
  flake.overlays = {
    inherit unstable apps;
  };

  den.aspects.overlays = {
    nixos.nixpkgs.overlays = [unstable apps];
    darwin.nixpkgs.overlays = [unstable apps];
  };
}

