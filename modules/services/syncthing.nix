{
  flake.modules.nixos.syncthing = { config, ... }: {
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8384 ];
    services.syncthing = {
      enable = true;
      dataDir = "/var/lib/syncthing";
      configDir = "/var/lib/syncthing/.config/syncthing";
      openDefaultPorts = true;          # 22000/tcp+udp, 21027/udp
      overrideDevices = true;
      overrideFolders = true;

      guiAddress = "0.0.0.0:8384";
      guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;
      settings = {
        gui = {
          address = "0.0.0.0:8384";
          user = "ivy";
        };
        devices = {
          aspen = { id = "34BRASD-JF433B5-65QROJF-7WRJZ74-LISAYBR-4ADQBVC-XXX672X-O7IAJA6"; };
          maple = { id = "5JH2CJ6-GEFOZAI-YTE2HIW-EK2NNHG-4CATBIM-WA4F2ZD-HUFTQIN-QXCBJAI"; };
          birch = { id = "IGGM65Q-7D3CXXE-WL2DZBQ-JFTAVZH-2IGGI3T-NNSEIOE-Y26ERF2-357RMQM"; };
        };
        folders."obsidian" = {
          id = "obsidian-vault";        # identical ID everywhere
          path = "/var/lib/syncthing/obsidian";
          devices = [ "aspen" "maple" "birch" ];
          ignorePerms = true;
          versioning = {
            type = "staggered";
            params = { cleanInterval = "3600"; maxAge = "2592000"; };   # elm doubles as vault history/backup
          };
        };
        options.urAccepted = -1;
      };
    };
  };

  flake.modules.homeManager.syncthing = { config, ... }: {
    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;

      settings = {
        devices = {
          elm   = { id = "TJPGEOG-GD5YAMM-47UEI4V-XTTAS4J-USDHS2B-JLNX4ED-NBEBUPF-WMYMOAC"; };
          maple = { id = "5JH2CJ6-GEFOZAI-YTE2HIW-EK2NNHG-4CATBIM-WA4F2ZD-HUFTQIN-QXCBJAI"; };
          birch = { id = "IGGM65Q-7D3CXXE-WL2DZBQ-JFTAVZH-2IGGI3T-NNSEIOE-Y26ERF2-357RMQM"; };
        };
        folders."obsidian" = {
          id = "obsidian-vault";        # identical ID everywhere
          path = "${config.home.homeDirectory}/Documents/obsidian";
          devices = [ "elm" "maple" "birch" ];
          ignorePerms = true;
        };
        options.urAccepted = -1;
      };
    };
  };
}
