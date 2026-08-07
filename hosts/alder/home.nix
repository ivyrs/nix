{den, ...}: {
  den.aspects.alder.provides.to-users = {
    includes = [
      den.aspects.home-manager
      den.aspects.ghostty
      den.aspects.desktop
      den.aspects.dev-tools
      den.aspects.emacs
      den.aspects.niri
      den.aspects.noctalia
      den.aspects.syncthing-client
      den.aspects.onepassword
      den.aspects.theme
      den.aspects.music
    ];

    homeManager = {
      config,
      lib,
      ...
    }: {
      # Auto-sync the calendars from modules/aspects/desktop/calendars.nix
      # every 5 min. This is a systemd user timer, Linux-only — aspen has no
      # systemd user session, so it stays a manual `vdirsyncer sync` there.
      services.vdirsyncer.enable = true;

      # alder-only: keep the obsidian vault under ~/text rather than the
      # ~/Documents/obsidian default from den.aspects.syncthing-client
      # (which aspen — a macOS host — still uses).
      services.syncthing.settings.folders.obsidian.path =
        lib.mkForce "${config.home.homeDirectory}/text/obsidian";
    };
  };
}
