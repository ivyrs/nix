{
  den.aspects.cli-tools.homeManager = {pkgs, ...}: {
    # Extend freely. Workstation-only tools live in desktop/default.nix.
    home.packages = with pkgs; [
      ripgrep
      fd
      jq
      # bat moved to den.aspects.bat (programs.bat configuration)
      eza
      duf
      btop
      dust
      procs
      sd
      just
      nh # `just switch` runs `nh os switch` on every host — keep in base
      ripgrep-all
      tokei
      # yazi moved to den.aspects.yazi (programs.yazi configuration)
      hyperfine
      xh
      mprocs
      kondo
    ];
  };
}
