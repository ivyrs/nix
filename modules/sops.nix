{
  # Shared by every NixOS host: file location + the ivy login password.
  # Per-service secrets live in `sops-elm-services` below since owners like
  # "forgejo"/"nextcloud" only exist as users on elm.
  flake.modules.nixos.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    sops.secrets.ivy-password-hash = {};
    # Shared glance-agent auth token: elm's glance dashboard uses it as a
    # client (see glance/_server-stats.nix) and every host running
    # den.aspects.glance-agent uses it as the server, so it's
    # declared here rather than in sops-elm-services below.
    sops.secrets.glance-agent-token = {};
  };

  # elm-only: secrets for services that only run there (forgejo/nextcloud
  # owners don't exist as users on houseplants/lovecomputer).
  flake.modules.nixos.sops-elm-services = {
    sops.secrets.glance-city = {};
    sops.secrets.syncthing-gui-password.owner = "syncthing";
    sops.secrets.miniflux-admin-credentials = {};
    sops.secrets.pocket-id-encryption-key = {};
    sops.secrets.vikunja-env = {};
    sops.secrets.vaultwarden-env = {};
    sops.secrets.nextcloud-admin-password.owner = "nextcloud";
    sops.secrets.nextcloud-oidc-client-secret.owner = "nextcloud";
    sops.secrets.nextcloud-smtp-password.owner = "nextcloud";
    sops.secrets.nextcloud-harp-shared-key-env = {};
    sops.secrets.gotosocial-env = {};
    sops.secrets.forgejo-internal-token.owner = "forgejo";
    sops.secrets.forgejo-oauth2-jwt-secret.owner = "forgejo";
    sops.secrets.forgejo-lfs-jwt-secret.owner = "forgejo";
  };

  flake.modules.darwin.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    # aerc's IMAP/SMTP password (see modules/aspects/aerc.nix); owned by ivy so
    # home-manager's passwordCommand can read it without sudo.
    sops.secrets.aerc-fastmail-password.owner = "ivy";
  };
}
