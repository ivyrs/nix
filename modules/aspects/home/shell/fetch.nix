{
  den.aspects.fetch.homeManager = {
    programs.hyfetch = {
      enable = true;
      settings = {
        preset = "baker";
        mode = "rgb";
        auto_detect_light_dark = true;
        light_dark = "dark";
        lightness = 0.65;
        color_align.mode = "vertical";
        backend = "macchina";
        args = null;
        pride_month_disable = false;
        custom_ascii_path = null;
        custom_presets = null;
        palette_glyph = null;
        palette_type = null;
      };
    };

    programs.macchina.enable = true;
  };
}
