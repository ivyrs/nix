{
  flake.modules.homeManager.base = { config, lib, ... }: {
    # Config only — the app itself comes from environment.systemPackages on
    # each host. Ghostty auto-injects zsh shell integration on macOS, so
    # nothing to enable here. Gated on gui.enable since this is pointless on
    # a headless host.
    config = lib.mkIf config.gui.enable {
      programs.ghostty = {
        enable = true;
        package = null;
        systemd.enable = false;
        settings = {
          theme = "Catppuccin Mocha";
          font-family = "IBM Plex Mono";
          font-size = 12;
          background-opacity = 0.96;
          cursor-style = "block";
          macos-titlebar-style = "tabs";
          window-padding-x = 10;
          window-padding-y = 10;
        };
      };
    };
  };
}
