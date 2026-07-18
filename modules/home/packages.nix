{
  flake.modules.homeManager.base = { pkgs, ... }: {
    # Extend freely. Workstation-only tools live in workstation.nix.
    home.packages = with pkgs; [
      ripgrep
      fd
      jq
      bat
      eza
      duf
      btop
      dust
      procs
      sd
      just
      nh # `just switch` runs `nh os switch` on every host — keep in base
    ];
  };

  # GUI-only apps: pointless on a headless host like elm.
  den.aspects.gui.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ discord ];
  };
}
