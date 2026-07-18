{
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      # A reverse proxy (caddy) is a known TODO — services currently sit on
      # bare ports behind the tailnet; this pre-authorises caddy for LE certs.
      permitCertUid = "caddy";
    };
  };
}
