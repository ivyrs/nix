{ config, den, ... }:
{
  den.aspects.aspen.provides.to-users = {
    includes = [ den.aspects.gui ];

    homeManager = {
      imports = [
        config.flake.modules.homeManager.base
        config.flake.modules.homeManager.syncthing
      ];
    };
  };
}
