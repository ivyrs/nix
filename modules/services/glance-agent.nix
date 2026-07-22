# Runs the glanceapp/agent companion binary so this host shows up as a
# "remote" server-stats entry on elm's glance dashboard (see
# modules/services/glance/_server-stats.nix). Not packaged in nixpkgs, so
# the derivation lives in modules/packages (underscore-prefixed so
# import-tree skips it — it's a plain callPackage function, not a
# flake-parts module).
{...}: {
  flake.modules.nixos.glance-agent = {
    config,
    pkgs,
    ...
  }: let
    package = pkgs.callPackage ../packages/_glance-agent.nix {};
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
