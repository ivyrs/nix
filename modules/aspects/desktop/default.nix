{
  # CLI tools that only make sense on an interactive workstation, not a
  # headless server. Hosts opt in via den.aspects.<host>.provides.to-users
  # (aspen and alder do; elm and houseplants deliberately don't).
  den.aspects.desktop.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      claude-code
      opencode
      pi-coding-agent
      gh
      # Secrets editing happens from a workstation (see README's sops notes).
      sops
      age
      ssh-to-age
      # Cross-platform GUI app, shared by every desktop host (aspen + alder).
      vesktop
    ];
  };

  # GUI apps for a Linux desktop session (currently just alder). Kept
  # nixos-only rather than in the homeManager block above: some (e.g.
  # nokkvi) are Linux-only packages, and that block is also included by
  # aspen (darwin) — putting them there would break aspen's build.
  den.aspects.desktop.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      keymapp
      firefox
    ];
  };
}
