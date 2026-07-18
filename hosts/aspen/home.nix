{ inputs, config, den, ... }:
{
  den.aspects.aspen.provides.to-users = {
    includes = [ den.aspects.gui ];

    homeManager = {
      imports = [
        inputs.nvf.homeManagerModules.default
        config.flake.modules.homeManager.base
        config.flake.modules.homeManager.syncthing
      ];
    };
  };
}
