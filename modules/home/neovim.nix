{
  flake.modules.homeManager.base = {
    programs.nvf = {
      enable = true;
      settings = {
        vim.viAlias = true;
        vim.vimAlias = true;

        vim.lsp.enable = true;
        vim.treesitter.enable = true;
        vim.telescope.enable = true;
        vim.statusline.lualine.enable = true;

        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        # nvf's catppuccin wrapper doesn't expose color_overrides, so re-run
        # setup ourselves after it (default DAG order puts this after the
        # entryBefore-tagged theme block) to swap mauve for lavender as the
        # accent hue.
        vim.luaConfigRC.catppuccin-lavender-accent = ''
          require('catppuccin').setup({
            flavour = "mocha",
            transparent_background = true,
            float = { transparent = true },
            color_overrides = {
              mocha = {
                mauve = "#b4befe",
              },
            },
          })
          vim.cmd.colorscheme "catppuccin"
        '';
      };
    };
  };
}
