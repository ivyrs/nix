{ inputs, config, ... }:
{
  den.aspects.aspen.provides.to-users.homeManager = {
    imports = [
      inputs.nvf.homeManagerModules.default
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.syncthing
    ];

    gui.enable = true;
  };
}
