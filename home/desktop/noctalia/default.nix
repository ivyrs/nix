{
  config,
  inputs,
  lib,
  metadata,
  pkgs,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
    ../../dev/neovim/module.nix
  ];

  home.packages = [ pkgs.ddcutil ];

  programs.noctalia = {
    enable = true;
    settings = pkgs.replaceVars ./noctalia.toml {
      home = metadata.user.homeDirectory;
      servicesDomain = metadata.domains.services;
      username = metadata.user.username;
    };
    systemd.enable = true;
  };

  # noctalia writes its generated theme directly into these apps' own config
  # paths at runtime. A non-empty home-manager-owned file at that exact path
  # is a read-only symlink into the nix store, so noctalia's write fails with
  # a permission error. Leave these empty or load a separate mutable theme. See
  # home/desktop/ghostty.nix, home/files/zathura.nix, home/dev/git/lazygit.nix,
  # home/pim/aerc/default.nix, home/shell/tmux/default.nix, home/shell/cli.nix
  # and home/media/music.nix for the mkDefault fallbacks these override.
  #
  # ncspot has no `include` directive and no separate theme-file mechanism —
  # its `[theme]` table has to live inside its one config.toml. So rather
  # than forcing an existing home-manager-owned file empty, music.nix simply
  # never defines xdg.configFile."ncspot/config.toml" at all, leaving that
  # path free for noctalia to own outright; the static settings that would
  # otherwise live there (e.g. use_nerdfont) are folded into the template
  # below instead.
  programs.ghostty.settings.theme = lib.mkForce "noctalia";

  programs.zathura.options = lib.mkForce { };
  programs.zathura.extraConfig = "include noctaliarc";

  # Noctalia owns config.yml; layer it over the static settings (Lazygit 0.61.1).
  home.file."${config.xdg.configHome}/lazygit/config.yml".enable = lib.mkForce false;
  programs.lazygit.package = pkgs.writeShellScriptBin "lazygit" ''
    if [ -z "''${LG_CONFIG_FILE:-}" ]; then
      export LG_CONFIG_FILE=${
        (pkgs.formats.yaml { }).generate "lazygit-static.yml" config.programs.lazygit.settings
      }
      if [ -f "${config.xdg.configHome}/lazygit/config.yml" ]; then
        LG_CONFIG_FILE="$LG_CONFIG_FILE,${config.xdg.configHome}/lazygit/config.yml"
      fi
    fi
    exec ${pkgs.lazygit}/bin/lazygit "$@"
  '';

  programs.atuin.settings.theme.name = "noctalia";
  programs.delta.options.syntax-theme = "noctalia";

  programs.aerc.extraConfig.ui.styleset-name = lib.mkForce "noctalia";
  programs.aerc.stylesets = lib.mkForce { };

  programs.fzf.defaultOptions = lib.mkForce [
    "--style=minimal"
    "--info=inline-right"
    "--highlight-line"
    "--no-separator"
  ];

  home.sessionVariablesExtra = ''
    [ -f "$HOME/.config/fzf/noctalia-colors.sh" ] && source "$HOME/.config/fzf/noctalia-colors.sh"
  '';

  programs.tmux.extraConfig = lib.mkAfter ''
    # Source noctalia-generated theme (will override hardcoded colors above)
    source-file -q ~/.config/tmux/noctalia-theme.conf
  '';

  home.file.".config/noctalia/templates/aerc.conf".source = ./templates/aerc.conf;
  home.file.".config/noctalia/templates/atuin.toml".source = ./templates/atuin.toml;
  home.file.".config/noctalia/templates/opencode.json".source = ./templates/opencode.json;
  home.file.".config/noctalia/templates/fzf.sh".source = ./templates/fzf.sh;
  home.file.".config/noctalia/templates/ncspot.toml".source = ./templates/ncspot.toml;
  home.file.".config/noctalia/templates/tmux.conf".source = ./templates/tmux.conf;
  home.file.".config/noctalia/templates/rmpc.ron".source = ./templates/rmpc.ron;

  # neovim: unlike the apps above, nvf never touches ~/.config/nvim at
  # runtime (it wraps a fully self-contained nix-store binary — no
  # xdg.configFile management and no live config directory on the
  # runtimepath), so noctalia can't theme it by overwriting a config file
  # in place. Instead its generated colors are rendered to a path nvf never
  # manages (~/.config/nvim-noctalia), and base16-nvim + a dofile() of that
  # path is wired in via luaConfigRC, applied at startup and again on
  # SIGUSR1 (this template's post_hook in noctalia.toml signals running
  # nvim instances to reload after a theme change).
  programs.nvf.settings.vim = {
    extraPlugins.base16-nvim.package = pkgs.vimPlugins.base16-nvim;

    luaConfigRC.noctalia-theme = {
      after = [ "mappings" ];
      before = [ ];
      data = ''
        local noctalia_theme_file = vim.fn.expand("~/.config/nvim-noctalia/matugen.lua")

        local noctalia_transparent_groups = {
          "Normal", "NormalNC", "NormalFloat", "FloatBorder", "NonText",
          "SignColumn", "EndOfBuffer", "LineNr", "CursorLineNr",
          "VertSplit", "WinSeparator", "StatusLine", "StatusLineNC",
          "TabLine", "TabLineFill", "Pmenu", "FoldColumn", "Folded",
          -- Telescope's floating window backdrops. Left alone on purpose:
          -- TelescopeSelection (row highlight, needed to see what's
          -- selected) and the Prompt/Preview/ResultsTitle badges (their
          -- accent-colored bg is a deliberate pill, not page background).
          "TelescopeNormal", "TelescopeBorder",
          "TelescopePromptNormal", "TelescopePromptBorder",
          "TelescopePromptPrefix", "TelescopeResultsNormal",
          "TelescopeResultsBorder", "TelescopePreviewNormal",
          "TelescopePreviewBorder",
        }

        local function apply_noctalia_theme()
          if vim.fn.filereadable(noctalia_theme_file) == 1 then
            local ok, matugen = pcall(dofile, noctalia_theme_file)
            if ok and matugen and matugen.setup then
              matugen.setup()

              -- base16-nvim paints a solid Normal background; strip it back
              -- out so the terminal's own (transparent) background shows
              -- through, matching vim.theme.transparent on non-noctalia hosts.
              for _, group in ipairs(noctalia_transparent_groups) do
                local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
                highlight.bg = nil
                vim.api.nvim_set_hl(0, group, highlight)
              end
            end
          end
        end

        apply_noctalia_theme()

        local noctalia_signal = vim.uv.new_signal()
        noctalia_signal:start("sigusr1", vim.schedule_wrap(apply_noctalia_theme))
      '';
    };
  };

  home.file.".config/nvim-noctalia/.keep".text = "";
  home.file.".config/noctalia/templates/nvim-matugen.lua".source = ./templates/nvim-matugen.lua;
}
