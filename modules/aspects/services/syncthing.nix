{
  config,
  lib,
  ...
}: let
  st = config.flake.lib.meta.syncthing;
  # Each machine lists every device except itself; IDs live in modules/meta/meta.nix.
  deviceSet = names: lib.genAttrs names (name: {id = st.devices.${name};});
in {
  den.aspects.syncthing.nixos = {config, ...}: {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [8384];
    services.syncthing = {
      enable = true;
      dataDir = "/var/lib/syncthing";
      configDir = "/var/lib/syncthing/.config/syncthing";
      openDefaultPorts = true; # 22000/tcp+udp, 21027/udp
      overrideDevices = true;
      overrideFolders = true;

      guiAddress = "0.0.0.0:8384";
      guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;
      settings = {
        gui = {
          address = "0.0.0.0:8384";
          user = "ivy";
        };
        devices = deviceSet ["aspen" "maple" "birch"];
        folders."obsidian" = {
          id = st.obsidianFolderId;
          path = "/var/lib/syncthing/obsidian";
          devices = ["aspen" "maple" "birch"];
          ignorePerms = true;
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            }; # elm doubles as vault history/backup
          };
        };
        options.urAccepted = -1;
      };
    };
  };

  # Separate aspect (not den.aspects.syncthing.homeManager) so NixOS desktops
  # like alder can pull in just the per-user client via provides.to-users,
  # without also pulling in the system-wide daemon above — an aspect's nixos
  # class applies host-wide regardless of which include path pulled it in, so
  # sharing one aspect name would make alder try (and fail, lacking elm's
  # syncthing-gui-password sops secret) to run the daemon too.
  den.aspects.syncthing-client.homeManager = {config, ...}: {
    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;

      settings = {
        devices = deviceSet ["elm" "maple" "birch"];
        folders."obsidian" = {
          id = st.obsidianFolderId;
          path = "${config.home.homeDirectory}/Documents/obsidian";
          devices = ["elm" "maple" "birch"];
          ignorePerms = true;
        };
        options.urAccepted = -1;
      };
    };
  };
}
