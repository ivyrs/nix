{inputs, ...}: {
  den.aspects.neovim.homeManager = {
    imports = [inputs.nvf.homeManagerModules.default];

    programs.nvf = {
      enable = true;
      settings = {
        vim.viAlias = true;
        vim.vimAlias = true;

        vim.lsp.enable = true;
        vim.treesitter.enable = true;
        vim.telescope.enable = true;
        vim.statusline.lualine.enable = true;

        # completion popup + snippets while typing
        vim.autocomplete.blink-cmp.enable = true;
        vim.autopairs.nvim-autopairs.enable = true;
        vim.comments.comment-nvim.enable = true;

        # git status in the gutter + a full git UI
        vim.git.gitsigns.enable = true;

        # keybind cheatsheet popup, indent guides, lsp progress spinner
        vim.binds.whichKey.enable = true;
        vim.visuals.indent-blankline.enable = true;
        vim.visuals.fidget-nvim.enable = true;

        vim.languages = {
          astro.enable = true;
          rust.enable = true;
          typescript.enable = true;
          clang.enable = true;
          html.enable = true;
          css.enable = true;
          go.enable = true;
          markdown.enable = true; # also mdx
        };

        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        vim.utility.oil-nvim.enable = true;

        # oil.nvim convention: `-` opens the parent directory of the
        # current buffer, mirroring vim-vinegar
        vim.keymaps = [
          {
            key = "-";
            mode = "n";
            action = "<CMD>Oil<CR>";
            desc = "Open parent directory (oil.nvim)";
          }
        ];

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
