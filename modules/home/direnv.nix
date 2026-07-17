{
  flake.modules.homeManager.base = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
