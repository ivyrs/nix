{ config, ... }:
let
  meta = config.flake.lib.meta;
in
{
  flake.modules.nixos.vaultwarden = { config, ... }: {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";

      config = {
        DOMAIN = "https://vault.${meta.domain}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;

        SSO_ENABLED = true;
        SSO_AUTHORITY = meta.oidcIssuer;
        SSO_CLIENT_ID = "91751e42-c596-4ef1-ba94-782e52fed1bc";
        SSO_PKCE = true;

        SMTP_HOST = meta.smtp.host;
        SMTP_SECURITY = "starttls";
        SMTP_PORT = meta.smtp.port;
        SMTP_USERNAME = meta.smtp.username;
        SMTP_FROM = "vault@${meta.domain}";
        SMTP_FROM_NAME = "Vaultwarden";
      };

      # ADMIN_TOKEN, SSO_CLIENT_SECRET, SMTP_PASSWORD live here since services.vaultwarden.config values end up plaintext in the nix store.
      environmentFile = config.sops.secrets.vaultwarden-env.path;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ config.services.vaultwarden.config.ROCKET_PORT ];
  };
}
