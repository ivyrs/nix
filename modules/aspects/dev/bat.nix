{
  den.aspects.bat.homeManager = {
    programs.bat = {
      enable = true;

      config = {
        # Let noctalia handle theming via its community template
        # Theme will be set dynamically by noctalia on noctalia hosts
        style = "numbers,changes,header";
        pager = "less -FR";
        tabs = "2";
        wrap = "never";
      };
    };
  };
}
