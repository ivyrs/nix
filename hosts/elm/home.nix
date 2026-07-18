{ inputs, config, ... }:
{
  den.aspects.elm.provides.to-users.homeManager = {
    imports = [
      inputs.nvf.homeManagerModules.default
      config.flake.modules.homeManager.base
    ];
  };
}
