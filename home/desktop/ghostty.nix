{ lib, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    systemd.enable = false;

    settings = lib.mkMerge [
      {
        theme = lib.mkDefault "Gruvbox Dark";

        font-family = "Aporetic Sans Mono";
        font-size = 14;
        background-opacity = 0.90;
        cursor-style = "block";
        window-padding-x = 10;
        window-padding-y = 10;
        confirm-close-surface = false;
      }

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        macos-titlebar-style = "tabs";
      })
    ];
  };
}
