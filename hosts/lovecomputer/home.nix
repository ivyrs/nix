{config, ...}: {
  den.aspects.lovecomputer.provides.to-users.homeManager = {
    imports = [
      config.flake.modules.homeManager.base
    ];
  };
}
