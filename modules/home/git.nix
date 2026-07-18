{ config, ... }:
let
  meta = config.flake.lib.meta;
in
{
  flake.modules.homeManager.base = {
    programs.git = {
      enable = true;
      settings = {
        user.name = "ivy forever";
        user.email = meta.email;
      };
    };

    programs.lazygit.enable = true;
  };
}
