{...}: {
  den.aspects.multi-scrobbler.nixos = {...}: {
    # Upstream (github.com/FoxxMD/multi-scrobbler) has a heavy native-dep
    # surface (mdns/dbus/avahi, patch-package, a Vite build) — a from-scratch
    # buildNpmPackage would be fragile for little benefit over their own image.
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
  };
}
