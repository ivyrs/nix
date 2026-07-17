{
  flake.modules.homeManager.base = { config, lib, pkgs, ... }: {
    # Extend freely.
    home.packages = with pkgs;
      [
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
      ]
      # GUI-only apps: pointless on a headless host like elm.
      ++ lib.optionals config.gui.enable [
        discord
      ];
  };
}
