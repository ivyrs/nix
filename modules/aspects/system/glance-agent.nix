# Runs the glanceapp/agent companion binary so this host shows up as a
# "remote" server-stats entry on elm's glance dashboard (see
# modules/aspects/system/glance/_server-stats.nix). Packaged at
# packages/glance-agent/ (see modules/meta/packages.nix, which also exposes
# it as flake.packages.<system>.glance-agent).
{...}: {
  den.aspects.glance-agent.nixos = {
    config,
    pkgs,
    ...
  }: let
    package = pkgs.callPackage ../../../packages/glance-agent/default.nix {};
    port = 27973;
  in {
    systemd.services.glance-agent = {
      description = "Glance agent (remote server-stats reporting)";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        LoadCredential = "token:${config.sops.secrets.glance-agent-token.path}";
        ExecStart = pkgs.writeShellScript "glance-agent-start" ''
          export TOKEN="$(cat "$CREDENTIALS_DIRECTORY/token")"
          export PORT=${toString port}
          exec ${package}/bin/glance-agent
        '';
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [port];
  };
}
