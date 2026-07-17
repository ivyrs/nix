{
  flake.modules.homeManager.base = {
    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}
