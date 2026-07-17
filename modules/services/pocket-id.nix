{
  flake.modules.nixos.pocket-id = { config, ... }: {
    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = "https://id.ivy.rs";
        TRUST_PROXY = true;
      };
      credentials.ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 1411 ];
  };
}
