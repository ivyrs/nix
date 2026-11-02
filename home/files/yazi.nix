{ lib, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  xdg.desktopEntries = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    yazi-directory = {
      name = "Yazi (directory)";
      comment = "Browse directories with Yazi in Ghostty";
      exec = "${pkgs.ghostty}/bin/ghostty --working-directory=%f -e ${pkgs.yazi}/bin/yazi";
      terminal = false;
      type = "Application";
      mimeType = [ "inode/directory" ];
    };
  };

  xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi-directory.desktop" ];
    };
  };
}
