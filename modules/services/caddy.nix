{ config, ... }:
let
  meta = config.flake.lib.meta;
in
{
  flake.modules.nixos.caddy = { pkgs, ... }:
    let
      staticSite = pkgs.runCommand "houseplants-static-site" { } ''
        mkdir -p $out
        cp ${./houseplants-index.html} $out/index.html
      '';
    in
    {
      services.caddy = {
        enable = true;
        email = meta.email;

        virtualHosts."${meta.domain}".extraConfig = ''
          root * ${staticSite}
          file_server
        '';

        virtualHosts."fedi.ivy.rs".extraConfig = ''
          encode zstd gzip
          reverse_proxy elm.${meta.tailnet}:9400 {
            flush_interval -1
          }
        '';

        virtualHosts."stardust.dog".extraConfig = ''
          redir * https://discord.gg/8ev6mm4yPm
        '';

        virtualHosts."nc.${meta.domain}" = {
          serverAliases = [ "cloud.${meta.domain}" ];
          extraConfig = ''
            header Strict-Transport-Security "max-age=15552000"
            reverse_proxy elm.${meta.tailnet}:80
          '';
        };

        virtualHosts."git.${meta.domain}".extraConfig = ''
          reverse_proxy elm.${meta.tailnet}:3001
        '';

        virtualHosts."rss.${meta.domain}".extraConfig = ''
          reverse_proxy elm.${meta.tailnet}:3000
        '';

        virtualHosts."id.${meta.domain}".extraConfig = ''
          reverse_proxy elm.${meta.tailnet}:1411
        '';

        virtualHosts."vault.${meta.domain}".extraConfig = ''
          reverse_proxy elm.${meta.tailnet}:8222
        '';

        virtualHosts."todo.${meta.domain}".extraConfig = ''
          reverse_proxy elm.${meta.tailnet}:3456
        '';
      };
    };
}
