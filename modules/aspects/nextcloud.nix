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
      hostName = "cloud.${meta.domain}";

      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminuser = "ivy";
        adminpassFile = config.sops.secrets.nextcloud-admin-password.path;
      };

      extraApps = {inherit (config.services.nextcloud.package.packages.apps) user_oidc;};
      # Declaring extraApps makes the module disable the App Store by
      # default (appstoreEnable defaults to null, which renders as
      # `appstoreenabled => false` in config.php whenever extraApps is
      # non-empty) — silently taking down both the regular app store and
      # AppAPI's ExApp store with it. Force it back on; user_oidc stays
      # nix-managed regardless since it's only ever installed via extraApps.
      appstoreEnable = true;

      # Recommended by Nextcloud's admin overview: run background jobs at a
      # low-usage hour (UTC) instead of no window at all, and bump the
      # opcache interned-strings buffer past its default (module warned it
      # was nearly full).
      settings = {
        maintenance_window_start = 1;
        default_phone_region = "GB"; # elm's timezone is Europe/London

        # nextcloud is the only nginx vhost on elm (no local reverse proxy —
        # see tailscale.nix's permitCertUid TODO), which makes it nginx's
        # default server for any Host header — add the tailnet name and the
        # old public hostname too so Nextcloud's own untrusted-domain check
        # doesn't reject them.
        trusted_domains = ["nc.${meta.domain}" "elm.${meta.tailnet}"];

        # Public HTTPS is terminated by a Caddy instance on a separate VPS,
        # which reaches elm over the tailnet and forwards plain HTTP to
        # nginx here. Without trusting its tailnet IP, Nextcloud can't tell
        # the original request was HTTPS (breaks user_oidc, which refuses to
        # run the OIDC flow unless it thinks the connection is HTTPS).
        trusted_proxies = ["100.64.20.1"];

        mail_smtpmode = "smtp";
        mail_smtpauth = true;
        mail_smtphost = meta.smtp.host;
        mail_smtpport = meta.smtp.port;
        # Nextcloud's mail_smtpsecure only accepts "" or "ssl" (implicit
        # TLS); leaving it "" is correct for STARTTLS on the submission
        # port (587), which is what Fastmail uses here.
        mail_smtpname = meta.smtp.username;
        mail_from_address = "cloud";
        mail_domain = meta.domain;
      };
      secrets.mail_smtppassword = config.sops.secrets.nextcloud-smtp-password.path;

      phpOptions."opcache.interned_strings_buffer" = "16";
    };

    # Registers houseplantsID (pocket-id) as a login provider for the
    # user_oidc app above. `occ user_oidc:provider` upserts by identifier,
    # so this is idempotent and safe to re-run on every deploy.
    #
    # unique-uid=0 + mapping-uid=preferred_username make OIDC login resolve
    # to the existing local "ivy" account (pocket-id's username for this
    # account, confirmed via its sqlite db) instead of user_oidc's default
    # behaviour of provisioning a separate hashed-uid account per provider —
    # first login already did that once; the duplicate got deleted by hand.
    systemd.services.nextcloud-oidc-provider = {
      description = "Register houseplantsID as a Nextcloud OIDC provider";
      after = ["nextcloud-setup.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "nextcloud";
        # Without a pre-populated $CREDENTIALS_DIRECTORY, the occ wrapper
        # tries to self-elevate via `systemd-run --uid=nextcloud` to load
        # services.nextcloud.secrets.* (needed since mail_smtppassword was
        # added below) — which fails outside an interactive/root session.
        # Declaring the same LoadCredential nextcloud-setup.service uses
        # avoids that path entirely.
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

    # AppAPI / External Apps (ExApps): HaRP is the current recommended deploy
    # daemon for NC32+ (the older Docker Socket Proxy is deprecated, slated
    # for removal in NC35 — see github.com/nextcloud/app_api's AGENTS.md).
    # Only the HaRP container touches the Docker socket; Nextcloud/php-fpm
    # only ever talks to HaRP's HTTP API over the shared key below.
    #
    # Nextcloud itself isn't containerized here, so HaRP runs with
    # --network=host (the app_api docs' explicit adaptation for a bare-metal
    # Nextcloud) so "localhost" from inside the container reaches nginx and
    # HaRP's own FRP port directly, no Docker network/port-publish needed.
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

    # Required, not just for browser/WebSocket access: ExApp lifecycle calls
    # (e.g. the heartbeat check during deploy) hit `nextcloud_url` + "/exapps/…"
    # expecting it to reach HaRP. Without this, every ExApp install fails
    # ("Error starting install of ExApp" / heartbeat 404s), confirmed via
    # `occ app_api:app:register --test-deploy-mode`. `nextcloud_url` above
    # points straight at elm's own nginx (not the external VPS Caddy), so
    # this belongs here rather than on that VPS.
    services.nginx.virtualHosts.${config.services.nextcloud.hostName}.locations."/exapps/" = {
      proxyPass = "http://127.0.0.1:8780";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    # Registers HaRP as AppAPI's default deploy daemon and makes sure app_api
    # itself is enabled. `daemon:register` is a no-op if a daemon named
    # "harp1" already exists, so this is safe to re-run every deploy. `--net`
    # is omitted since its default ("host") already matches the container
    # above.
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

    # app_api hardcodes `proc_open('php console.php ...')` (AppAPIService::runOccCommandInternal)
    # with no config override, relying on a bare `php` resolving via php-fpm's
    # own PATH — which NixOS's nextcloud module never provides (only the
    # `nextcloud-occ` wrapper, which references its php-with-extensions build
    # by full store path). Without this, Test Deploy and ExApp installs fail
    # with "Error starting install of ExApp" (stderr: "php: command not found").
    # Referencing the pool's own phpPackage (not a fresh `pkgs.php`) keeps the
    # exact same extension set occ/php-fpm already use.
    environment.systemPackages = [config.services.phpfpm.pools.nextcloud.phpPackage];

    # services.nextcloud pulls in services.nginx (mkDefault true) to front php-fpm.
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80];
  };
}
