{
  lib,
  metadata,
  pkgs,
  ...
}:

{
  home = {
    username = metadata.user.username;
    homeDirectory = metadata.user.homeDirectory;
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  # Keep the shared Git configuration without gitFull's graphical tools.
  programs.git.package = lib.mkForce pkgs.git;
}
