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
        devices = deviceSet ["aspen" "alder" "maple" "birch"];
        folders."obsidian" = {
          id = st.obsidianFolderId;
          path = "/var/lib/syncthing/obsidian";
          devices = ["aspen" "alder" "maple" "birch"];
          ignorePerms = true;
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            }; # elm doubles as vault history/backup
          };
        };
        # alder-only for now: aspen doesn't have the GPG key den.aspects.pass
        # relies on yet, so it can't decrypt anything in here anyway. Same
        # staggered versioning as obsidian — elm is the backup/history copy,
        # not a device anyone types a passphrase into day-to-day.
        folders."password-store" = {
          id = st.passwordStoreFolderId;
          path = "/var/lib/syncthing/password-store";
          devices = ["alder"];
          ignorePerms = true;
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
        options.urAccepted = -1;
      };
    };
  };

  # Separate aspect (not den.aspects.syncthing.homeManager) so alder can pull
  # in just the per-user client via provides.to-users without also pulling
  # in the system-wide daemon above — an aspect's nixos class applies
  # host-wide regardless of include path, so sharing one name would make
  # alder try (and fail, lacking elm's syncthing-gui-password secret) to run
  # the daemon too.
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
