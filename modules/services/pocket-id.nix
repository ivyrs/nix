{config, ...}: let
  meta = config.flake.lib.meta;
in {
  flake.modules.nixos.pocket-id = {config, ...}: {
    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = meta.oidcIssuer;
        TRUST_PROXY = true;
      };
      credentials.ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [1411];
  };
}
