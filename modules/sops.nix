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
  };

  flake.modules.darwin.sops = {
    sops.defaultSopsFile = ../secrets/secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Canary, not dead code: sops-nix's darwin module is entirely
    # `mkIf (secrets != {})`, so without at least one secret nothing gets
    # decrypted at activation and a broken host key would go unnoticed
    # until a real secret needs it.
    sops.secrets.placeholder = { };
  };
}
