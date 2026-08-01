{
  # PLACEHOLDER — alder's physical Asahi install hasn't happened yet.
  # Replace this file wholesale with the real output of
  # `nixos-generate-config` run on alder's hardware once it exists; do not
  # hand-edit it after that (see AGENTS.md guardrails on generated hardware
  # files, same rule as elm/houseplants/lovecomputer).
  #
  # The fake root filesystem below exists only so `nix flake check` (which
  # evaluates every nixosConfiguration, alder included) doesn't fail on a
  # missing-root-fs assertion repo-wide while the physical install is
  # pending — it's discarded along with the rest of this file.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
