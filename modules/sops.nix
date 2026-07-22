{
  flake.modules.nixos.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets.glance-city = { };
    sops.secrets.syncthing-gui-password.owner = "syncthing";
    sops.secrets.miniflux-admin-credentials = { };
    sops.secrets.pocket-id-encryption-key = { };
    sops.secrets.vikunja-env = { };
    sops.secrets.glance-agent-token = { };
    sops.secrets.vaultwarden-env = { };
    sops.secrets.nextcloud-admin-password.owner = "nextcloud";
    sops.secrets.nextcloud-oidc-client-secret.owner = "nextcloud";
    sops.secrets.nextcloud-smtp-password.owner = "nextcloud";
    sops.secrets.nextcloud-harp-shared-key-env = { };
    sops.secrets.gotosocial-env = { };
    sops.secrets.forgejo-internal-token.owner = "forgejo";
    sops.secrets.forgejo-oauth2-jwt-secret.owner = "forgejo";
    sops.secrets.forgejo-lfs-jwt-secret.owner = "forgejo";
  };

  flake.modules.darwin.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # aerc's IMAP/SMTP password (see modules/home/aerc.nix); owned by ivy so
    # home-manager's passwordCommand can read it without sudo.
    sops.secrets.aerc-fastmail-password.owner = "ivy";
  };
}
