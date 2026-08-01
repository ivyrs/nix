{...}: {
  den.aspects.multi-scrobbler.nixos = {...}: {
    # Upstream (github.com/FoxxMD/multi-scrobbler) is a Node/TS app with a
    # heavy native-dependency surface (mdns/dbus/avahi bindings) plus a
    # patch-package postinstall step and a separate Vite frontend build —
    # packaging it as a from-scratch buildNpmPackage derivation would be a
    # large, fragile undertaking for little benefit over running the image
    # upstream actually builds/tests.
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.multi-scrobbler = {
      image = "foxxmd/multi-scrobbler";
      autoStart = true;
      ports = ["9078:9078"];
      volumes = ["/var/lib/multi-scrobbler/config:/config"];
      environment = {
        TZ = "Europe/London"; # elm's timezone (see nextcloud.nix's default_phone_region)
        # linuxserver base image; match the root:root ownership tmpfiles sets below.
        PUID = "0";
        PGID = "0";
      };
    };
    systemd.tmpfiles.rules = ["d /var/lib/multi-scrobbler/config 0700 root root -"];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [9078];
  };
}
