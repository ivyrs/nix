{
  # CLI tools that only make sense on an interactive workstation, not a
  # headless server. Hosts opt in via den.aspects.<host>.provides.to-users
  # (aspen does; elm deliberately doesn't).
  den.aspects.workstation.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      claude-code
      gh
      # Secrets editing happens from a workstation (see README's sops notes).
      sops
      age
      ssh-to-age
      devenv

      # Default dev toolchains. Rust comes via rustup rather than nixpkgs'
      # rustc/cargo so `rustup target add wasm32-unknown-unknown` works
      # in-place; run that once after activation to get wasm support.
      nodejs
      rustup
      go
    ];
  };
}
