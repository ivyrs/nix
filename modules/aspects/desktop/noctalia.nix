{inputs, ...}: {
  # noctalia is a Quickshell-based Wayland shell/bar for niri, replacing
  # waybar. See https://docs.noctalia.dev/v5/getting-started/installation/
  # (NixOS-specific steps: https://docs.noctalia.dev/v5/getting-started/nixos/)
  den.aspects.noctalia.nixos = {
    imports = [inputs.noctalia.nixosModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      # Wires up NetworkManager, Bluetooth, UPower, and power-profiles-daemon,
      # which noctalia's wifi/bluetooth/power-profile/battery widgets need.
      recommendedServices.enable = true;
    };
  };

  den.aspects.noctalia.homeManager = {lib, ...}: {
    imports = [inputs.noctalia.homeModules.default];

    # lazygit's home-manager module only symlinks ~/.config/lazygit/config.yml
    # when its settings are non-empty (see git.nix); forcing this to {} here
    # keeps that file a plain mutable dotfile so noctalia's lazygit template
    # can write its theme into it at runtime instead of hitting a read-only
    # nix-store symlink. This does mean the os.editPreset/git.pagers/gui
    # defaults from git.nix don't apply on noctalia hosts — re-add them by
    # hand in the now-mutable config.yml if you want them back.
    programs.lazygit.settings = lib.mkForce {};

    # See ghostty.nix: only noctalia hosts actually render a "noctalia"
    # ghostty theme file, so only they should reference it.
    programs.ghostty.settings.theme = lib.mkForce "noctalia";

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      # noctalia merges this in as a *background default* under whatever's
      # already in the live ~/.local/state/noctalia/settings.toml (that file
      # always wins key-for-key) — so this seeds a fresh install with today's
      # tuned setup without ever fighting further tweaks made through
      # noctalia's own settings UI. See noctalia-settings.toml for the file
      # itself and the reasoning in more depth.
      settings = ./noctalia-settings.toml;
    };
  };
}
