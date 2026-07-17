{
  flake.modules.nixos.vaultwarden = { config, ... }: {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";

      config = {
        DOMAIN = "https://vault.houseplants.cloud";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;

        SSO_ENABLED = true;
        SSO_AUTHORITY = "https://id.houseplants.cloud";
        SSO_CLIENT_ID = "91751e42-c596-4ef1-ba94-782e52fed1bc";
        SSO_PKCE = true;

        SMTP_HOST = "smtp.fastmail.com";
        SMTP_SECURITY = "starttls";
        SMTP_PORT = 587;
        SMTP_USERNAME = "ivy@ivy.rs";
        SMTP_FROM = "vault@houseplants.cloud";
        SMTP_FROM_NAME = "Vaultwarden";
      };

      # ADMIN_TOKEN, SSO_CLIENT_SECRET, SMTP_PASSWORD live here since services.vaultwarden.config values end up plaintext in the nix store.
      environmentFile = config.sops.secrets.vaultwarden-env.path;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ config.services.vaultwarden.config.ROCKET_PORT ];
  };
}
