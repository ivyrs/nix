# gamja — web IRC client for soju (./soju.nix). Contributes to
# den.aspects.soju alongside soju.nix rather than its own aspect (Den merges
# aspect config across files) since it's just soju's web frontend, not a
# standalone service.
#
# Served two ways under the same svc:bnc Tailscale Service as soju's raw IRC
# port (soju.nix's tailscale-serve-bnc unit): tailscaled serves gamja's
# static build directly (`tailscale serve` can host a local directory with
# no separate web server needed) at "/", and reverse-proxies "/socket" to
# soju's own websocket listener underneath it. gamja's default config
# (unset here) already points at "/socket", so this needs no config.json —
# it Just Works from the same origin.
{...}: {
  den.aspects.soju.nixos = {
    config,
    pkgs,
    ...
  }: {
    services.soju.listen = [
      # loopback-only, like soju.nix's irc+insecure listener — fronted by
      # tailscale-serve-bnc-web below.
      "http+insecure://127.0.0.1:6699"
    ];

    systemd.services.tailscale-serve-bnc-web = {
      description = "Advertise gamja + soju's websocket under the bnc Tailscale Service";
      after = ["tailscaled.service" "soju.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      partOf = ["tailscaled.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "2s";
        ExecStart = pkgs.writeShellScript "tailscale-serve-bnc-web-start" ''
          set -e
          ${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --https=443 ${pkgs.gamja}
          ${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --https=443 --set-path=/socket http://127.0.0.1:6699/socket
        '';
        ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:bnc --https=443 off";
      };
    };
  };
}
