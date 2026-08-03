{
  den.aspects.tmux.homeManager = {
    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile ./tmux.conf;
    };
  };
}
