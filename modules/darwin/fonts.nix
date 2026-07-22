{
  flake.modules.darwin.fonts = {pkgs, ...}: {
    # Fonts installed here are visible to GUI apps like Ghostty.
    fonts.packages = with pkgs; [ibm-plex];
  };
}
