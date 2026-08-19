# Glance dashboard. The _*.nix files here are underscore-prefixed so
# import-tree skips them: they are plain functions/attrsets imported below,
# NOT flake-parts modules. (settings.pages is a list, so it can't be merged
# from several registering modules — hence explicit imports.)
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.glance.nixos = {config, ...}: {
    sops.secrets.glance-city = {};
    sops.secrets.glance-agent-token = {};

    services.glance = {
      enable = true;
      settings = {
        server = {
          host = "127.0.0.1";
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
                  (import ./_monitor-sites.nix {inherit meta;})
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

    # Exposed as a Tailscale Service (svc:dash -> dash.<tailnet>.ts.net) via
    # the `tailscale serve` CLI's --https flag, not the declarative
    # services.tailscale.serve.services option: as of tailscaled 1.98.x, the
    # JSON config path can only ever produce a plain-HTTP tcp:<port>
    # listener, whatever backend scheme you give it — only --https makes
    # tailscaled terminate TLS and provision the cert. Config also doesn't
    # survive a tailscaled restart, so this re-asserts on every start.
    systemd.services.tailscale-serve-dash = {
      description = "Advertise glance as the dash Tailscale Service";
      after = ["tailscaled.service" "glance.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      partOf = ["tailscaled.service"];
      # tailscaled.service can report "active" before its backend state
      # machine has actually reached Running (bare `after` ordering isn't
      # enough), so `tailscale serve` right after a tailscaled restart can
      # fail with "unexpected state: NoState" — retry rather than fail once.
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "2s";
        ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:dash --https=443 8080";
        ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:dash --https=443 off";
      };
    };
  };
}
