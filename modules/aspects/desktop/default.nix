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
      # Terminal markdown renderer.
      glow
    ];
  };

  # GUI apps for a Linux desktop session (currently just alder). Kept
  # nixos-only rather than in the homeManager block above: some (e.g.
  # nokkvi) are Linux-only packages, and that block is also included by
  # aspen (darwin) — putting them there would break aspen's build.
  den.aspects.desktop.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # nixpkgs' `keymapp` GUI is x86_64-only upstream (ZSA doesn't ship an
      # aarch64 Linux build) despite meta.platforms claiming aarch64-linux
      # support — it's a genuine packaging bug, not something fixable from
      # here, and fails with "Exec format error" on alder (Apple Silicon).
      # `zapp` is ZSA's CLI flasher and builds natively for aarch64-linux.
      zapp
      firefox
      mpv
      imv
    ];
  };
}
