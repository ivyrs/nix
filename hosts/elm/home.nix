{config, ...}: {
  den.aspects.elm.provides.to-users.homeManager = {
    imports = [
      config.flake.modules.homeManager.base
    ];
  };
}
