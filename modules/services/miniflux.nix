{
  flake.modules.nixos.miniflux = { config, ... }: {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "0.0.0.0:3000";
        BASE_URL = "http://elm.ocelot-perch.ts.net:3000";
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_CLIENT_ID = "046ab3a0-0b0a-4eb8-92d9-4feb1b0e6fb5";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.houseplants.cloud";
        OAUTH2_REDIRECT_URL = "http://elm.ocelot-perch.ts.net:3000/oauth2/oidc/callback";
        OAUTH2_USER_CREATION = 1;
        DISABLE_LOCAL_AUTH = 1;
      };
      # OAUTH2_CLIENT_SECRET lives in this EnvironmentFile alongside ADMIN_USERNAME/ADMIN_PASSWORD,
      # since services.miniflux.config values end up plaintext in the systemd unit in /nix/store.
      adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3000 ];
  };
}
