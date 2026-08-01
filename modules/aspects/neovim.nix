{inputs, ...}: {
  den.aspects.neovim.homeManager = {
    # nvf's HM module ships the programs.nvf options themselves, so it lives
    # here with its config rather than in each host's home.nix.
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
          java.enable = true;
          typescript.enable = true;
          elixir.enable = true;
          clang.enable = true;
          html.enable = true;
          css.enable = true;
          go.enable = true;
          # covers .mdx too - nvf maps that extension to the markdown
          # filetype (treesitter, marksman LSP, formatting, diagnostics)
          markdown.enable = true;
        };

        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        vim.utility.oil-nvim = {
          # good file manager
          enable = true;
        };

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

        # vim.notes.obsidian.enable = true;
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
