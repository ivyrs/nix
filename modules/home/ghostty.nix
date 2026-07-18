{
  # Config only — the app itself comes from environment.systemPackages on
  # each host. Ghostty auto-injects zsh shell integration on macOS, so
  # nothing to enable here. Lives in the `gui` aspect since this is
  # pointless on a headless host.
  den.aspects.gui.homeManager = {
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
}
