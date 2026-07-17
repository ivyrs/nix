{
  flake.modules.nixos.vikunja = { config, ... }: {
    services.postgresql = {
      enable = true;
      ensureUsers = [
        { name = "vikunja"; ensureDBOwnership = true; }
      ];
      ensureDatabases = [ "vikunja" ];
    };

    services.vikunja = {
      enable = true;
      frontendScheme = "https";
      frontendHostname = "todo.houseplants.cloud";

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
          providers.ivyid = {
            name = "ivyid";
            authurl = "https://id.ivy.rs";
            clientid = "9a681736-b7ce-4b16-ac94-22276d57657c";
            scope = "openid profile email";
          };
        };
        mailer = {
          enabled = true;
          host = "smtp.fastmail.com";
          port = 587;
          username = "ivy@ivy.rs";
          fromemail = "todo@houseplants.cloud";
        };
      };

      environmentFiles = [ config.sops.secrets.vikunja-env.path ];
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ config.services.vikunja.port ];
  };
}
