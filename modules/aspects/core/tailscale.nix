# NixOS only — aspen runs the Tailscale mac app (homebrew cask
# "tailscale-app"), configured through its GUI.
{
  # Devices that just join the tailnet: can use exit nodes and subnet
  # routes advertised by others, doesn't advertise anything itself.
  den.aspects.tailscale-client.nixos = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };

  # Devices that advertise routes/exit-node (enables IP forwarding).
  den.aspects.tailscale-server.nixos = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      # A reverse proxy (caddy) is a known TODO — services currently sit on
      # bare ports behind the tailnet; this pre-authorises caddy for LE certs.
      permitCertUid = "caddy";
    };

    # useRoutingFeatures = "server" makes the tailscale module set
    # net.ipv6.conf.all.forwarding = true. Linux's kernel treats that as
    # "this is a router" and stops autoconfiguring the box's own address via
    # SLAAC RAs unless accept_ra is explicitly overridden to 2 (accept RAs
    # even with forwarding on). Without this, houseplants (whose public
    # IPv6 comes purely from Hetzner SLAAC) silently ends up with only a
    # link-local address and no default v6 route.
    boot.kernel.sysctl = {
      "net.ipv6.conf.all.accept_ra" = 2;
      "net.ipv6.conf.default.accept_ra" = 2;
    };
  };
}
