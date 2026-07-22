{
  flake.modules.darwin.system-defaults = {
    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        show-recents = false;
        persistent-apps = [
          {app = "/Applications/Nix Apps/Ghostty.app";}
          {app = "/Applications/Helium.app";}
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
