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

  den.aspects.noctalia.homeManager = {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        # Recommended alongside systemd.enable: without it, apps launched
        # through noctalia get killed whenever its service restarts.
        shell.launch_apps_as_systemd_services = true;
      };
    };
  };
}
