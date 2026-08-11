# Ergo IRC daemon (services.ergochat — nixpkgs also ships an unrelated
# services.ergo for the Ergo cryptocurrency node, don't confuse the two).
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.ergo.nixos = {
    config,
    lib,
    ...
  }: {
    services.ergochat = {
      enable = true;
      settings = {
        network.name = meta.tailnet;
        server = {
          name = "irc.${meta.tailnet}";
          # mkForce, not a merge: the module re-asserts its own default
          # (":6667" = {}) as a plain, non-mkDefault value (mapAttrsRecursive
          # never touches an empty attrset, since it has no leaves to
          # recurse into), so a same-priority override on just that key
          # conflicts instead of winning. Replacing the whole set is the
          # only reachable-over-loopback-only option — fronted by the
          # tailscale-serve-irc unit below.
          listeners = lib.mkForce {"127.0.0.1:6667" = {};};
        };
      };
    };

    # Exposed as a Tailscale Service (svc:irc -> irc.<tailnet>.ts.net) the
    # same way glance is (see ../glance/default.nix): tailscaled terminates
    # TLS on the tailnet cert via --tls-terminated-tcp and forwards plain
    # TCP to ergo's loopback listener. This has to go through the `tailscale
    # serve` CLI rather than the declarative services.tailscale.serve
    # option, which (as of tailscaled 1.98.x) can only produce plain-HTTP
    # tcp:<port> listeners. Config also doesn't survive a tailscaled
    # restart, so this re-asserts on every start.
    #
    # --tls-terminated-tcp's listen port MUST match the backend port: unlike
    # --https (which registers the Tailscale Service under its own listen
    # port, e.g. dash's 443), a TCP-type service's canonical port is taken
    # from the *backend* target, not the flag's argument. A mismatched pair
    # (tried --tls-terminated-tcp=6697 -> tcp://127.0.0.1:6667) silently
    # registered the service as tcp:6667 tailnet-wide while tailscaled kept
    # listening on 6697 locally — reachable from nowhere else on the tailnet.
    systemd.services.tailscale-serve-irc = {
      description = "Advertise ergo as the irc Tailscale Service";
      after = ["tailscaled.service" "ergochat.service"];
      wants = ["tailscaled.service"];
      wantedBy = ["multi-user.target"];
      partOf = ["tailscaled.service"];
      # tailscaled.service can report "active" before its backend state
      # machine has actually reached Running (bare `after` ordering isn't
      # enough), so `tailscale serve` right after a tailscaled restart can
      # fail with "unexpected state: NoState" — retry rather than fail once.
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "2s";
        ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:irc --tls-terminated-tcp=6667 tcp://127.0.0.1:6667";
        ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --service=svc:irc --tls-terminated-tcp=6667 off";
      };
    };
  };
}
