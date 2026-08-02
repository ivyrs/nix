{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.forgejo.nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo; # fountain tracked the rolling "15" tag, not forgejo-lts
      database.type = "postgres"; # createDatabase defaults true -> local peer auth via /run/postgresql
      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = "git.${meta.domain}";
          ROOT_URL = "https://git.${meta.domain}/";
          HTTP_PORT = 3001; # 3000 is already taken by miniflux on elm
          # git+ssh is tailnet-only; no NAT in front of it, so the listen port
          # and the port shown in clone URLs are the same.
          SSH_DOMAIN = "elm.${meta.tailnet}";
          SSH_PORT = 2222;
          START_SSH_SERVER = true;
        };

        service = {
          DISABLE_REGISTRATION = true;
          ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
          ENABLE_INTERNAL_SIGNIN = false;
          REGISTER_EMAIL_CONFIRM = false;
          ENABLE_NOTIFY_MAIL = false;
          DEFAULT_ALLOW_CREATE_ORGANIZATION = true;
          DEFAULT_ENABLE_TIMETRACKING = true;
          ENABLE_CAPTCHA = false;
        };

        security = {
          REVERSE_PROXY_LIMIT = 1;
          # tailnet IP of the external Caddy proxy that fronts the other
          # houseplants.cloud services (see modules/aspects/nextcloud.nix)
          REVERSE_PROXY_TRUSTED_PROXIES = "100.64.20.1";
        };

        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
          ACCOUNT_LINKING = "auto";
          OPENID_CONNECT_SCOPES = "email profile";
          UPDATE_AVATAR = true;
        };

        mailer.ENABLED = false;

        ui = {
          THEMES = "catppuccin-red-auto,catppuccin-mocha-red,catppuccin-latte-red";
          DEFAULT_THEME = "catppuccin-red-auto";
        };

        other = {
          SHOW_FOOTER_VERSION = false;
          SHOW_FOOTER_POWERED_BY = false;
          SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
        };

        "repository.pull-request".DEFAULT_MERGE_STYLE = "merge";
        "repository.signing".DEFAULT_TRUST_MODEL = "committer";
        "cron.update_checker".ENABLED = true;
      };

      # Carried over verbatim from the fountain instance so existing sessions,
      # API tokens, and LFS auth stay valid across the migration. SECRET_KEY
      # was blank on fountain too (confirmed nothing relies on it), so it's
      # left on the module's default self-generating path instead of sops.
      secrets = {
        security.INTERNAL_TOKEN = lib.mkForce config.sops.secrets.forgejo-internal-token.path;
        oauth2.JWT_SECRET = lib.mkForce config.sops.secrets.forgejo-oauth2-jwt-secret.path;
        server.LFS_JWT_SECRET = lib.mkForce config.sops.secrets.forgejo-lfs-jwt-secret.path;
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
      config.services.forgejo.settings.server.HTTP_PORT
      2222
    ];

    # forgejo-secrets.service reads services.forgejo.secrets.* directly as the
    # unprivileged forgejo user (unlike forgejo.service itself, which uses
    # systemd's LoadCredential). Its ReadWritePaths puts it in a private mount
    # namespace, which hides sops-nix's /run/secrets.d unless bound in.
    systemd.services.forgejo-secrets.serviceConfig.BindReadOnlyPaths = ["/run/secrets.d" "/run/secrets"];
  };
}
