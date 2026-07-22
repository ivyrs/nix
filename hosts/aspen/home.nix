{
  config,
  den,
  ...
}: {
  den.aspects.aspen.provides.to-users = {
    includes = [
      den.aspects.gui
      den.aspects.workstation
    ];

    homeManager = {
      imports = [
        config.flake.modules.homeManager.base
        config.flake.modules.homeManager.syncthing
      ];
    };
  };
}
