{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.miniflux.nixos = {config, ...}: {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "0.0.0.0:3000";
        BASE_URL = "https://rss.${meta.domain}";
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_CLIENT_ID = "046ab3a0-0b0a-4eb8-92d9-4feb1b0e6fb5";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = meta.oidcIssuer;
        OAUTH2_REDIRECT_URL = "https://rss.${meta.domain}/oauth2/oidc/callback";
        OAUTH2_USER_CREATION = 1;
        DISABLE_LOCAL_AUTH = 1;
      };
      # OAUTH2_CLIENT_SECRET lives in this EnvironmentFile alongside ADMIN_USERNAME/ADMIN_PASSWORD,
      # since services.miniflux.config values end up plaintext in the systemd unit in /nix/store.
      adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;
    };
  };
}
