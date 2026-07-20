{ config, inputs, ... }:
let
  meta = config.flake.lib.meta;
in
{
  flake.modules.nixos.gotosocial = { config, pkgs, ... }:
    let
      # Migrated from a hand-run Docker instance on 0.22.0; the flake's
      # pinned nixpkgs (nixos-26.05, "stable") only has 0.21.3 and GtS
      # doesn't support downgrading a DB once migrated forward, so this
      # pulls just this one package from the unstable input instead of
      # bumping the shared stable pin for every host.
      package = inputs.nixpkgs.legacyPackages.${pkgs.system}.gotosocial;

      # Mirrors the old setup's docker bind-mount of a custom theme.css
      # over the shipped assets dir.
      themedAssets = pkgs.runCommand "gotosocial-themed-assets" { } ''
        cp -r ${package}/share/gotosocial/web/assets $out
        chmod -R u+w $out
        cp ${./gotosocial-theme.css} $out/themes/theme.css
      '';
    in
    {
      services.gotosocial = {
        enable = true;
        inherit package;
        environmentFile = config.sops.secrets.gotosocial-env.path;
        settings = {
          host = "fedi.ivy.rs";
          account-domain = "ivy.rs";

          bind-address = "0.0.0.0";
          port = 9400;

          db-type = "sqlite";
          db-address = "/var/lib/gotosocial/storage/sqlite.db";

          # Media/emoji/attachment storage lives in a private B2 bucket
          # (S3-compatible API); the sqlite DB above still lives on local
          # disk regardless of this setting, GtS never puts the DB in
          # object storage. storage-s3-proxy=true means GtS streams bytes
          # from B2 through itself rather than 303-redirecting clients to
          # presigned B2 URLs — keeps every URL under fedi.ivy.rs and the
          # bucket fully private, at the cost of elm's own bandwidth.
          storage-backend = "s3";
          storage-s3-endpoint = "s3.eu-central-003.backblazeb2.com";
          storage-s3-region = "eu-central-003";
          storage-s3-use-ssl = true;
          storage-s3-proxy = true;
          storage-s3-bucket = "ivy-gotosocial";

          web-asset-base-dir = "${themedAssets}/";

          # Public HTTPS is terminated by a Caddy instance on the
          # houseplants VPS, which reaches elm over the tailnet — same
          # arrangement as nextcloud (see nextcloud.nix's trusted_proxies
          # comment). Without this, GtS treats the connection as plain
          # HTTP and OIDC/redirects break.
          trusted-proxies = [ "100.64.20.1" ];

          letsencrypt-enabled = false;

          oidc-enabled = true;
          oidc-idp-name = "houseplantsID";
          oidc-issuer = meta.oidcIssuer;
          oidc-client-id = "6aa09792-1602-405a-a7ed-adcdc4b3883c";
        };
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 9400 ];
    };
}
