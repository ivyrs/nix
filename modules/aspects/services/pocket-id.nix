{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.pocket-id.nixos = {config, ...}: {
    sops.secrets.pocket-id-encryption-key = {};

    services.pocket-id = {
      enable = true;
      settings = {
        APP_URL = meta.oidcIssuer;
        TRUST_PROXY = true;
      };
      credentials.ENCRYPTION_KEY = config.sops.secrets.pocket-id-encryption-key.path;
    };
  };
}
