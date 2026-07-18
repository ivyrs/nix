{
  flake.modules.homeManager.base = { pkgs, ... }: {
    # Extend freely.
    home.packages = with pkgs; [
      ripgrep
      fd
      jq
      bat
      eza
      claude-code
      duf
      btop
      dust
      procs
      sd
      just
      sops
      age
      ssh-to-age
      nh
      gh
    ];
  };

  # GUI-only apps: pointless on a headless host like elm.
  den.aspects.gui.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ discord ];
  };
}
