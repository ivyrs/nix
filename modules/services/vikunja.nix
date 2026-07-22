{config, ...}: let
  meta = config.flake.lib.meta;
in {
  flake.modules.nixos.vikunja = {config, ...}: {
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vikunja";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = ["vikunja"];
    };

    services.vikunja = {
      enable = true;
      frontendScheme = "https";
      frontendHostname = "todo.${meta.domain}";

      database = {
        type = "postgres";
        host = "/run/postgresql";
        user = "vikunja";
        database = "vikunja";
      };

      settings = {
        service.motd = "meow";
        auth.local.enabled = false;
        auth.openid = {
          enabled = true;
          providers.houseplants = {
            name = "houseplantsID";
            authurl = meta.oidcIssuer;
            clientid = "9a681736-b7ce-4b16-ac94-22276d57657c";
            scope = "openid profile email";
          };
        };
        mailer = {
          enabled = true;
          host = meta.smtp.host;
          port = meta.smtp.port;
          username = meta.smtp.username;
          fromemail = "todo@${meta.domain}";
        };
      };

      environmentFiles = [config.sops.secrets.vikunja-env.path];
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [config.services.vikunja.port];
  };
}
