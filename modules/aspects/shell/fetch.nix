{
  den.aspects.fetch.homeManager = {
    programs.hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        auto_detect_light_dark = true;
        light_dark = "dark";
        lightness = 0.65;
        color_align.mode = "vertical";
        backend = "fastfetch";
        args = null;
        pride_month_disable = false;
        custom_ascii_path = null;
        custom_presets = null;
        palette_glyph = null;
        palette_type = null;
      };
    };

    programs.fastfetch = {
      enable = true;
      # A trimmed-down module list (fastfetch's stock config is quite
      # noisy — battery/locale/bluetooth/etc.) plus tighter spacing and a
      # closing colour swatch row. hyfetch recolors the logo itself; this
      # only shapes the info panel next to it.
      settings = {
        logo.padding = {
          top = 1;
          right = 2;
        };
        display = {
          separator = "  ";
          key.width = 10;
        };
        modules = [
          "title"
          "break"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "terminal"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "break"
          "colors"
        ];
      };
    };
  };
}
