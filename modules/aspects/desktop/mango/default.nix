{inputs, ...}: {
  # mango (dwm but wayland: https://mangowm.github.io/) is added as an
  # additional selectable session alongside den.aspects.niri, not a
  # replacement — niri stays the ly default (set by niri's own nixpkgs
  # module via services.displayManager.defaultSession).
  den.aspects.mango.nixos = {
    imports = [inputs.mango.nixosModules.mango];

    programs.mango.enable = true;
  };

  den.aspects.mango.homeManager = {
    imports = [inputs.mango.hmModules.mango];

    wayland.windowManager.mango = {
      enable = true;
      settings = import ./_settings.nix;

      # mango only writes ~/.config/mango/config.conf's exec-once line (which
      # runs the dbus/systemd activation that starts mango-session.target ->
      # graphical-session.target) when autostart_sh is non-empty — so this
      # no-op is what actually gets noctalia's systemd user service (already
      # WantedBy=graphical-session.target) running under mango. Niri doesn't
      # need this since it starts that target natively on its own.
      autostart_sh = ":";
    };
  };
}
