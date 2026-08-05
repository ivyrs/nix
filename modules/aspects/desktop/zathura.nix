{lib, ...}: {
  den.aspects.desktop.homeManager = {
    programs.zathura = {
      enable = true;

      # Catppuccin Mocha, lavender accent — matches ghostty/lazygit theming
      # (see git.nix). mkDefault: noctalia hosts override this via `include`
      # instead (see noctalia.nix), so this is only the fallback for hosts
      # without noctalia (aspen).
      options = lib.mkDefault {
        default-bg = "#1e1e2e";
        default-fg = "#cdd6f4";

        statusbar-bg = "#313244";
        statusbar-fg = "#cdd6f4";

        inputbar-bg = "#1e1e2e";
        inputbar-fg = "#cdd6f4";

        notification-bg = "#1e1e2e";
        notification-fg = "#cdd6f4";
        notification-error-bg = "#1e1e2e";
        notification-error-fg = "#f38ba8";
        notification-warning-bg = "#1e1e2e";
        notification-warning-fg = "#f38ba8";

        highlight-color = "#f9e2af";
        highlight-active-color = "#f5c2e7";

        completion-bg = "#1e1e2e";
        completion-fg = "#cdd6f4";
        completion-group-bg = "#1e1e2e";
        completion-group-fg = "#cdd6f4";
        completion-highlight-bg = "#b4befe";
        completion-highlight-fg = "#1e1e2e";

        index-bg = "#1e1e2e";
        index-fg = "#cdd6f4";
        index-active-bg = "#b4befe";
        index-active-fg = "#1e1e2e";

        render-loading-bg = "#1e1e2e";
        render-loading-fg = "#cdd6f4";

        # Off by default so PDF pages keep their native colors (figures,
        # embedded images, etc). Toggle at runtime with <C-r> for documents
        # that read better with a dark background.
        recolor = false;
        recolor-lightcolor = "#1e1e2e";
        recolor-darkcolor = "#cdd6f4";
        recolor-keephue = true;
      };

      mappings = {
        "<C-r>" = "recolor";
      };
    };
  };
}
