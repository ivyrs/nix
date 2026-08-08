{
  den.aspects.ghostty.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    programs.ghostty = {
      enable = true;
      package =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ghostty-bin
        else pkgs.ghostty;
      systemd.enable = false;
      settings = lib.mkMerge [
        {
          # set this as mkDefault so we can override with noctalia
          theme = lib.mkDefault "Catppuccin Mocha";
          font-family = "Aporetic Sans Mono";
          font-size = 14;
          background-opacity = 0.90;
          cursor-style = "block";
          window-padding-x = 10;
          window-padding-y = 10;
          confirm-close-surface = false;

          keybind = [
            "super+v=paste_from_clipboard"
          ];
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          macos-titlebar-style = "tabs";
        })
      ];
    };
  };
}
