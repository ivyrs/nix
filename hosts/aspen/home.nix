{den, ...}: {
  den.aspects.aspen.provides.to-users = {
    includes = [
      den.aspects.home-manager
      den.aspects.ghostty
      den.aspects.desktop
      den.aspects.dev-tools
      den.aspects.syncthing-client
      den.aspects.onepassword
      den.aspects.music
    ];

    homeManager = {
      home.file.".ssh/authorized_keys".text = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ aspen
      '';
    };
  };
}
