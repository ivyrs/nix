{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.nextcloud.nixos = {
    config,
    pkgs,
    ...
  }: {
    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud34;
      hostName = "cloud.${meta.domain}";

      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminuser = "ivy";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };

      extraApps = {inherit (config.services.nextcloud.package.packages.apps) user_oidc;};
      # extraApps being non-empty makes the module default appstoreEnable to
      # null (renders as false), silently disabling both the App Store and
      # AppAPI's ExApp store. Force it back on; user_oidc stays nix-managed
      # regardless since it's only ever installed via extraApps.
      appstoreEnable = true;

      # Background jobs at a low-usage UTC hour, and opcache's
      # interned-strings buffer bumped past default (module warned it was
      # nearly full) — both per Nextcloud's admin overview.
      settings = {
        maintenance_window_start = 1;
        default_phone_region = "GB"; # elm's timezone is Europe/London

        # nextcloud is elm's only nginx vhost (no local reverse proxy — see
        # tailscale.nix's permitCertUid TODO), making it nginx's default
        # server for any Host header — add the tailnet name and old public
        # hostname too so Nextcloud's untrusted-domain check doesn't reject them.
        trusted_domains = ["nc.${meta.domain}" "elm.${meta.tailnet}"];

        # Public HTTPS terminates at a Caddy instance on a separate VPS,
        # which forwards plain HTTP to nginx here over the tailnet. Without
        # trusting its IP, Nextcloud can't tell the request was HTTPS
        # (breaks user_oidc, which requires HTTPS for the OIDC flow).
        trusted_proxies = ["100.64.20.1"];

        mail_smtpmode = "smtp";
        mail_smtpauth = true;
        mail_smtphost = meta.smtp.host;
        mail_smtpport = meta.smtp.port;
        # mail_smtpsecure only accepts "" or "ssl" (implicit TLS); "" is
        # correct for STARTTLS on submission port 587 (Fastmail here).
        mail_smtpname = meta.smtp.username;
        mail_from_address = "cloud";
        mail_domain = meta.domain;
      };
      secrets.mail_smtppassword = config.sops.secrets.nextcloud-smtp-password.path;

      phpOptions."opcache.interned_strings_buffer" = "16";
    };

    # Registers houseplantsID (pocket-id) as a login provider for user_oidc.
    # `occ user_oidc:provider` upserts by identifier, safe to re-run on every
    # deploy. unique-uid=0 + mapping-uid=preferred_username make OIDC login
    # resolve to the existing local "ivy" account (confirmed via pocket-id's
    # sqlite db) instead of provisioning a separate hashed-uid account —
    # first login already did that once; the duplicate was deleted by hand.
    systemd.services.nextcloud-oidc-provider = {
      description = "Register houseplantsID as a Nextcloud OIDC provider";
      after = ["nextcloud-setup.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "nextcloud";
        # Without a pre-populated $CREDENTIALS_DIRECTORY, occ tries to
        # self-elevate via `systemd-run --uid=nextcloud` to load
        # services.nextcloud.secrets.* (needed since mail_smtppassword),
        # which fails outside an interactive/root session. Declaring the
        # same LoadCredential nextcloud-setup.service uses avoids that.
        LoadCredential = "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}";
        ExecStart = pkgs.writeShellScript "nextcloud-oidc-provider-setup" ''
          ${config.services.nextcloud.occ}/bin/nextcloud-occ user_oidc:provider houseplants \
            --clientid="f6af92ea-3466-4a98-bd68-528446898f60" \
            --clientsecret-file="${config.sops.secrets.nextcloud-oidc-client-secret.path}" \
            --discoveryuri="${meta.oidcIssuer}/.well-known/openid-configuration" \
            --scope="openid email profile" \
            --unique-uid=0 \
            --mapping-uid=preferred_username
        '';
      };
    };

    # twofactor_totp ships with Nextcloud core but starts disabled; enabling
    # it just makes the option available to accounts, doesn't force 2FA on
    # anyone. `occ app:enable` is idempotent.
    systemd.services.nextcloud-enable-totp = {
      description = "Enable Nextcloud's TOTP two-factor app";
      after = ["nextcloud-setup.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "nextcloud";
        # See the comment on nextcloud-oidc-provider above.
        LoadCredential = "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}";
        ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ app:enable twofactor_totp";
      };
    };

    # With only the one houseplants OIDC provider registered above,
    # allow_multiple_user_backends=0 makes Nextcloud's login page redirect
    # straight to it instead of showing the local username/password form.
    # This doesn't remove local passwords — WebDAV, CalDAV/CardDAV, sync
    # clients, and occ still authenticate locally — and `?direct=1` on the
    # login URL always still reaches the classic form (Nextcloud's own
    # documented escape hatch, kept deliberately so a pocket-id outage can't
    # lock out recovery). `occ config:app:set` is idempotent.
    systemd.services.nextcloud-oidc-only-login = {
      description = "Make houseplants OIDC the default Nextcloud login, skipping the local form";
      after = ["nextcloud-setup.service" "nextcloud-oidc-provider.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "nextcloud";
        # See the comment on nextcloud-oidc-provider above.
        LoadCredential = "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}";
        ExecStart = "${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set user_oidc allow_multiple_user_backends --value=0 --type=integer";
      };
    };

    # AppAPI/ExApps: HaRP is the recommended deploy daemon for NC32+ (Docker
    # Socket Proxy is deprecated, removal in NC35 — see app_api's AGENTS.md).
    # Only the HaRP container touches the Docker socket; php-fpm only talks
    # to HaRP's HTTP API over the shared key below. Nextcloud isn't
    # containerized here, so HaRP runs with --network=host (app_api docs'
    # bare-metal adaptation) so "localhost" in-container reaches nginx and
    # HaRP's FRP port directly, no Docker network/port-publish needed.
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.appapi-harp = {
      image = "ghcr.io/nextcloud/nextcloud-appapi-harp:release";
      autoStart = true;
      extraOptions = ["--network=host"];
      environmentFiles = [config.sops.secrets.nextcloud-harp-shared-key-env.path];
      environment.NC_INSTANCE_URL = "http://elm.${meta.tailnet}";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/appapi-harp/certs:/certs"
      ];
    };
    systemd.tmpfiles.rules = ["d /var/lib/appapi-harp/certs 0700 root root -"];

    # Required for more than browser/WebSocket access: ExApp lifecycle calls
    # (e.g. deploy's heartbeat check) hit `nextcloud_url` + "/exapps/…"
    # expecting it to reach HaRP. Without this, every ExApp install fails
    # ("Error starting install of ExApp" / heartbeat 404s — confirmed via
    # `occ app_api:app:register --test-deploy-mode`). `nextcloud_url` points
    # at elm's own nginx, not the external VPS Caddy, so this lives here.
    services.nginx.virtualHosts.${config.services.nextcloud.hostName}.locations."/exapps/" = {
      proxyPass = "http://127.0.0.1:8780";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    # Registers HaRP as AppAPI's default deploy daemon and enables app_api.
    # `daemon:register` no-ops if "harp1" already exists, safe to re-run
    # every deploy. `--net` omitted since its default ("host") already
    # matches the container above.
    systemd.services.nextcloud-appapi-harp-register = {
      description = "Register HaRP as Nextcloud's AppAPI deploy daemon";
      after = ["nextcloud-setup.service" "docker-appapi-harp.service"];
      wants = ["docker-appapi-harp.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "nextcloud";
        LoadCredential = [
          "mail_smtppassword:${config.sops.secrets.nextcloud-smtp-password.path}"
          "harp_shared_key_env:${config.sops.secrets.nextcloud-harp-shared-key-env.path}"
        ];
        ExecStart = pkgs.writeShellScript "nextcloud-appapi-harp-register" ''
          HP_SHARED_KEY="$(cut -d= -f2- < "$CREDENTIALS_DIRECTORY/harp_shared_key_env")"
          ${config.services.nextcloud.occ}/bin/nextcloud-occ app:enable app_api
          ${config.services.nextcloud.occ}/bin/nextcloud-occ app_api:daemon:register harp1 "HaRP" docker-install http localhost:8780 "http://elm.${meta.tailnet}" \
            --harp \
            --harp_frp_address "localhost:8782" \
            --harp_shared_key "$HP_SHARED_KEY" \
            --set-default
        '';
      };
    };

    # app_api hardcodes `proc_open('php console.php ...')`
    # (AppAPIService::runOccCommandInternal), relying on a bare `php` on
    # PATH — which the nextcloud module never provides (only the
    # full-store-path `nextcloud-occ` wrapper). Without this, ExApp installs
    # fail with "php: command not found". Using the pool's own phpPackage
    # (not a fresh `pkgs.php`) keeps the same extension set occ/php-fpm use.
    environment.systemPackages = [config.services.phpfpm.pools.nextcloud.phpPackage];
  };
}
