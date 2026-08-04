{
  den.aspects.ghostty.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    programs.ghostty = {
      enable = true;
      # nixpkgs can't build ghostty from source on macOS yet, so Darwin
      # hosts get the official signed ghostty-bin instead.
      package =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ghostty-bin
        else pkgs.ghostty;
      systemd.enable = false;
      # mkMerge so the Darwin-only key below stays a proper option
      # definition (and can be lib.mkIf-gated) rather than a plain
      # attribute nested inside this set, which mkIf can't gate correctly.
      settings = lib.mkMerge [
        {
          # mkDefault: aspen (macOS) has no noctalia to render a "noctalia"
          # ghostty theme, so it keeps this Catppuccin fallback. Hosts with
          # noctalia force this to "noctalia" (see noctalia.nix) to pick up
          # the dynamically-generated theme file instead.
          theme = lib.mkDefault "Catppuccin Mocha";
          font-family = "Aporetic Sans Mono";
          font-size = 14;
          background-opacity = 0.96;
          cursor-style = "block";
          window-padding-x = 10;
          window-padding-y = 10;
        }
        # macos-titlebar-style is a macOS-only Ghostty config key; this
        # aspect is shared with alder (Linux), whose ghostty rejects it at
        # `+validate-config` on activation if it's written unconditionally.
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          macos-titlebar-style = "tabs";
        })
      ];
    };
  };
}
