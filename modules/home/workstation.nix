{
  # CLI tools that only make sense on an interactive workstation, not a
  # headless server. Hosts opt in via den.aspects.<host>.provides.to-users
  # (aspen does; elm deliberately doesn't).
  den.aspects.workstation.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [
      claude-code
      gh
      # Secrets editing happens from a workstation (see README's sops notes).
      sops
      age
      ssh-to-age
    ];
  };
}
