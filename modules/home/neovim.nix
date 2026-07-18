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

        vim.utility.oil-nvim = { # good file manager
          enable = true;
        };

        vim.notes.obsidian.enable = true;
        vim.notes.todo-comments.enable = true;

        # use lavender accents
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
