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

      home.file.".ssh/authorized_keys".text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ aspen
      '';
    };
  };
}
