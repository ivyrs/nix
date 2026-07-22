{ config, ... }:
{
  den.aspects.houseplants.provides.to-users.homeManager = {
    imports = [
      config.flake.modules.homeManager.base
    ];
  };
}
