{
  config,
  inputs,
  ...
}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.gotosocial.nixos = {
    config,
    pkgs,
    ...
  }: let
    package = inputs.nixpkgs.legacyPackages.${pkgs.system}.gotosocial;

    themedAssets = pkgs.runCommand "gotosocial-themed-assets" {} ''
      cp -r ${package}/share/gotosocial/web/assets $out
      chmod -R u+w $out
      cp ${./theme.css} $out/themes/theme.css
    '';
  in {
    sops.secrets.gotosocial-env = {};

    services.gotosocial = {
      enable = true;
      inherit package;
      environmentFile = config.sops.secrets.gotosocial-env.path;
      settings = {
        host = "fedi.ivy.rs";
        account-domain = "ivy.rs";

        landing-page-user = "ivy";

        bind-address = "0.0.0.0";
        port = 9400;

        db-type = "sqlite";
        db-address = "/var/lib/gotosocial/storage/sqlite.db";

        storage-backend = "s3";
        storage-s3-endpoint = "s3.eu-central-003.backblazeb2.com";
        storage-s3-region = "eu-central-003";
        storage-s3-use-ssl = true;
        storage-s3-proxy = true;
        storage-s3-bucket = "ivy-gotosocial";

        web-asset-base-dir = "${themedAssets}/";

        trusted-proxies = ["100.64.20.1"];

        letsencrypt-enabled = false;

        oidc-enabled = true;
        oidc-idp-name = "houseplantsID";
        oidc-issuer = meta.oidcIssuer;
        oidc-client-id = "6aa09792-1602-405a-a7ed-adcdc4b3883c";
      };
    };
  };
}
