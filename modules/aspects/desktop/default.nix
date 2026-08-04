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

  # GUI apps for a Linux desktop session (currently just alder). Kept nixos-only
  # rather than folded into the homeManager block above: several of these
  # (e.g. nokkvi) are packaged Linux-only in nixpkgs, and this aspect's
  # homeManager side is also included by aspen (darwin) — putting them there
  # would break aspen's build.
  den.aspects.desktop.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      obsidian
      calibre
      keymapp
      firefox
      feishin
      (pkgs.callPackage ../../../packages/nokkvi/default.nix {})
    ];
  };
}
