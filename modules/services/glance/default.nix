# Glance dashboard. The _*.nix files here are underscore-prefixed so
# import-tree skips them: they are plain functions/attrsets imported below,
# NOT flake-parts modules. (settings.pages is a list, so it can't be merged
# from several registering modules — hence explicit imports.)
{ config, ... }:
let
  meta = config.flake.lib.meta;
in
{
  flake.modules.nixos.glance = { config, ... }: {
    services.glance = {
      enable = true;
      settings = {
        server = {
          host = "0.0.0.0";
          port = 8080;
          assets-path = ./assets;
        };
        theme = {
          background-color = "240 21.1 14.9";
          primary-color = "232 97.4 85.1";
          contrast-multiplier = 1.1;
          custom-css-file = "/assets/user.css";
        };
        pages = [
          {
            name = "Home";
            hide-desktop-navigation = true;
            columns = [
              {
                size = "full";
                widgets = [
                  (import ./_clock-weather.nix {
                    cityFile = config.sops.secrets.glance-city.path;
                  })
                  (import ./_monitor-sites.nix { inherit meta; })
                  (import ./_server-stats.nix {
                    inherit meta;
                    tokenFile = config.sops.secrets.glance-agent-token.path;
                  })
                  (import ./_bookmarks.nix)
                ];
              }
            ];
          }
        ];
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8080 ];
  };
}
