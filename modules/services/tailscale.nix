# NixOS only — aspen runs the Tailscale mac app (homebrew cask
# "tailscale-app"), configured through its GUI.
{
  # Devices that just join the tailnet: can use exit nodes and subnet
  # routes advertised by others, doesn't advertise anything itself.
  flake.modules.nixos.tailscale-client = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
  };

  # Devices that advertise routes/exit-node (enables IP forwarding).
  flake.modules.nixos.tailscale-server = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      # A reverse proxy (caddy) is a known TODO — services currently sit on
      # bare ports behind the tailnet; this pre-authorises caddy for LE certs.
      permitCertUid = "caddy";
    };
  };
}
