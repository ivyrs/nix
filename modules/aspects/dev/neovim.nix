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
          python.enable = true;
        };

        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        vim.utility.oil-nvim.enable = true;
        vim.dashboard.alpha.enable = true;

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

        # custom alpha-nvim dashboard with ascii art
        vim.luaConfigRC.alpha-custom = ''
          local alpha = require('alpha')
          local dashboard = require('alpha.themes.dashboard')

          -- Custom header (ASCII art)
          dashboard.section.header.val = {
            [[   ╭──────────╮  ]],
            [[   │  NEOVIM  │  ]],
            [[   ╰──────────╯  ]],
          }

          -- Custom buttons
          dashboard.section.buttons.val = {
            dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
            dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
            dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
          }

          -- Footer
          local function footer()
            local total_plugins = vim.fn.len(vim.fn.globpath(vim.o.runtimepath, "plugin", 0, 1))
            local datetime = os.date(" %d-%m-%Y   %H:%M:%S")
            local version = vim.version()
            local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

            return datetime .. nvim_version_info
          end

          dashboard.section.footer.val = footer()

          -- Layout
          dashboard.config.layout = {
            { type = "padding", val = 2 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            dashboard.section.footer,
          }

          -- Apply catppuccin mocha colors
          dashboard.section.header.opts.hl = "Function"
          dashboard.section.buttons.opts.hl = "Keyword"
          dashboard.section.footer.opts.hl = "Comment"

          alpha.setup(dashboard.config)

          -- Disable folding on alpha buffer
          vim.cmd([[
            autocmd FileType alpha setlocal nofoldenable
          ]])
        '';
      };
    };
  };
}
