{ metadata, ... }:

{
  home = {
    username = metadata.user.username;
    homeDirectory = metadata.user.homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./chat
    ./desktop
    ./dev
    ./files
    ./media
    ./productivity
    ./security
    ./shell
    ./shell/tmux
  ];
}
