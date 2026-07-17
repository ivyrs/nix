{
  flake.modules.homeManager.base = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "ivy forever";
        user.email = "ivy@ivy.rs";
      };
    };

    programs.lazygit.enable = true;
  };
}
