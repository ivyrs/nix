{den, ...}: {
  den.aspects.ivy = {
    # define-user/primary-user are parametric on { host, user } so they
    # resolve per-platform: OS user + home.username/homeDirectory
    # everywhere, wheel/networkmanager on NixOS, system.primaryUser on
    # Darwin.
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    # Shared across every NixOS host (elm/houseplants/lovecomputer): the
    # login shell, declarative password, and the aspen SSH pubkey used for
    # unattended remote deploys. Den auto-applies this aspect to every host
    # with an `ivy` user since it's name-matched, so this fires on all three
    # without being listed in any host's `includes`.
    nixos = {
      pkgs,
      config,
      ...
    }: {
      users.users.ivy = {
        description = "ivy";
        shell = pkgs.zsh;
        hashedPasswordFile = config.sops.secrets.ivy-password-hash.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ aspen"
        ];
      };

      programs.zsh.enable = true;
    };
  };
}
