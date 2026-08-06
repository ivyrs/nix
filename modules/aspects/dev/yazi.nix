{
  den.aspects.yazi.homeManager = {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      shellWrapperName = "y";  # Use new default, silence warning
      
      settings = {
        manager = {
          show_hidden = false;
          sort_by = "alphabetical";
          sort_sensitive = false;
          sort_reverse = false;
          linemode = "none";
          show_symlink = true;
        };
        
        preview = {
          tab_size = 2;
          max_width = 600;
          max_height = 900;
        };
        
        opener = {
          edit = [
            { run = ''nvim "$@"''; block = true; for = "unix"; }
          ];
          open = [
            { run = ''open "$@"''; desc = "Open"; for = "macos"; }
            { run = ''xdg-open "$@"''; desc = "Open"; for = "linux"; }
          ];
        };
      };

      # Key bindings - keep minimal, yazi has good defaults
      keymap = {
        manager.prepend_keymap = [
          { on = [ "l" ]; run = "plugin --sync smart-enter"; desc = "Enter the child directory, or open the file"; }
          { on = [ "<C-s>" ]; run = "search fd"; desc = "Search files by name using fd"; }
          { on = [ "<C-S>" ]; run = "search rg"; desc = "Search files by content using ripgrep"; }
        ];
      };
    };
  };
}