{
  flake.modules.nixos.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets.placeholder = { };
    sops.secrets.glance-city = { };
    sops.secrets.syncthing-gui-password.owner = "syncthing";
    sops.secrets.miniflux-admin-credentials = { };
    sops.secrets.pocket-id-encryption-key = { };
    sops.secrets.vikunja-env = { };
    sops.secrets.glance-agent-token = { };
    sops.secrets.vaultwarden-env = { };
  };

  flake.modules.darwin.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    sops.secrets.placeholder = { };
  };
}
