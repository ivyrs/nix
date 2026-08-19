# sops-nix bootstrap only (file location + host age key) — every host needs
# this regardless of which secrets it actually decrypts, since
# modules/users/ivy.nix's shared `ivy` aspect declares ivy-password-hash on
# all of them. Individual `sops.secrets.<name>` declarations live next to
# whichever aspect actually consumes them, not here.
{
  den.aspects.sops = {
    nixos = {
      sops.defaultSopsFile = ../../../secrets.yaml;
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };

    darwin = {
      sops.defaultSopsFile = ../../../secrets.yaml;
      sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
  };
}
