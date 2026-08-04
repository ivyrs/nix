{den, ...}: {
  den.aspects.ivy = {
    # define-user/primary-user are parametric on { host, user }: OS user +
    # home.username/homeDirectory everywhere, wheel/networkmanager on NixOS,
    # system.primaryUser on Darwin.
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    # Login shell, declarative password, and the aspen SSH pubkey for
    # unattended remote deploys. Den auto-applies this to every host with an
    # `ivy` user (name-matched), so it fires on elm/houseplants without
    # being listed in either host's `includes`.
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: {
      users.users.ivy = {
        description = "ivy";
        shell = pkgs.zsh;
        # mkDefault so hosts with a physical console/greetd login (alder)
        # can override with an easier-to-type password than the shared
        # random one every other (headless, SSH-key-only) host uses.
        hashedPasswordFile = lib.mkDefault config.sops.secrets.ivy-password-hash.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ aspen"
        ];
      };

      programs.zsh.enable = true;
    };
  };
}
