{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.lovecomputer-caddy.nixos = {
    services.caddy = {
      enable = true;
      email = meta.email;

      virtualHosts."lovecomputer.net".extraConfig = ''
        root * /opt/sites/lovecomputer.net
        file_server
      '';

      virtualHosts."dont-th.ink".extraConfig = ''
        redir * https://thei.rs/spiral
      '';

      virtualHosts."ivy.rs" = {
        serverAliases = ["ivyro.se"];
        extraConfig = ''
          root * /opt/sites/ivy.rs
          file_server

          handle_errors {
            rewrite * /{err.status_code}.html
            file_server
          }

          route {
            @short path /-/* /ln/*
            redir @short https://ivy.omg.lol/{path.2}
          }

          route {
            redir /@ivy https://fedi.ivy.rs/@ivy
            redir /.well-known/host-meta* https://fedi.ivy.rs{uri} permanent
            redir /.well-known/webfinger* https://fedi.ivy.rs{uri} permanent
            redir /.well-known/nodeinfo* https://fedi.ivy.rs{uri} permanent
          }

          route {
            redir /git https://git.lovecomputer.net/ivy
          }
        '';
      };

      virtualHosts."75b44b3.whimpe.rs".extraConfig = ''
        root * /opt/sites/ivyrose.gay
        file_server
      '';

      virtualHosts."laker.gay".extraConfig = ''
        redir * https://ivy.rs 301
      '';

      virtualHosts."ivyrose.mom".extraConfig = ''
        redir * https://xela.zone
      '';

      virtualHosts."id.ivy.rs".extraConfig = ''
        reverse_proxy elm.${meta.tailnet}:1411
      '';
    };
  };
}
