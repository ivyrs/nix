{
  den.aspects.system-defaults.darwin = {
    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        show-recents = false;
        persistent-apps = [
          {app = "/Applications/Nix Apps/Ghostty.app";}
          {app = "/Applications/Helium.app";}
          {app = "/Applications/Obsidian.app";}
          {app = "/Applications/Nix Apps/Vesktop.app";}
          {app = "/Applications/Feishin.app";}
        ];
      };
      finder = {
        AppleShowAllExtensions = true;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
      };
    };
  };
}
