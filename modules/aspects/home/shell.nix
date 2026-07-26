# The interactive shell as one concern: zsh itself, the starship prompt,
# and the fzf/zoxide/direnv integrations hooked into it.
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.shell.homeManager = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "brew" "eza"];
      };

      initContent = ''
        zstyle ':completion:*' menu select
      '';

      shellAliases = {
        e = "nvim";

        # base aliases from https://github.com/plttn/fish-eza
        l = "eza --group --header --group-directories-first";
        ls = "eza --group --header --group-directories-first";
        ll = "eza --group --header --group-directories-first --long --git";
        le = "eza --group --header --group-directories-first --extended --long";
        lt = "eza --group --header --group-directories-first --tree --level";
        lc = "eza --group --header --group-directories-first --across";
        lo = "eza --group --header --group-directories-first --oneline";

        la = "eza -la";
        lsa = "eza -la";
        lta = "eza -T -a";
        tree = "eza --group --header --group-directories-first --tree";

        cat = "bat";
        df = "duf";
        top = "btop";
        find = "fd";
        grep = "rg";
        du = "dust";
        ps = "procs";
        sed = "sd";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "-" = "cd -";

        c = "clear";
        mkdir = "mkdir -p";
        reload = "exec zsh";

        lg = "lazygit";

        # justfile shortcuts (see ./justfile at the flake root)
        jsw = "just switch";
        jck = "just check";
        jfmt = "just fmt";
        jup = "just update";
        jdep = "just deploy";

        # nix maintenance
        nixgc = "nix-collect-garbage -d";
        nixgens = "nix-env --list-generations -p /nix/var/nix/profiles/system";

        ports = "lsof -i -P -n | grep LISTEN";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = " $username$hostname$directory$character";
        right_format = "$all";

        directory.style = "bright-white";

        character = {
          success_symbol = "[>](purple)";
          error_symbol = "[>](red)";
          vimcmd_symbol = "[<](green)";
        };

        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };

        git_status = {
          format = "[[(* $conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "";
          conflicted = "";
          untracked = "u";
          modified = "m";
          staged = "s";
          renamed = "r";
          deleted = "x";
          stashed = "st";
        };

        git_state = {
          format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
          style = "bright-black";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };

        username = {
          style_user = "purple";
          format = "[$user]($style)[@](white)";
          disabled = false;
        };

        hostname = {
          ssh_symbol = " ssh";
          format = "[$hostname](purple)[$ssh_symbol](bold blue) ";
          trim_at = ".";
          aliases = {
            "aspen.${meta.tailnet}" = "aspen";
            "elm.${meta.tailnet}" = "elm";
          };
          disabled = false;
        };
      };
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--style=minimal"
        "--info=inline-right"
        "--highlight-line"
        "--no-separator"
        "--color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8,fg+:#cdd6f4,bg+:#313244"
        "--color=hl+:#f38ba8,info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc"
        "--color=marker:#f8ebe8,spinner:#f5e0dc,header:#f38ba8,border:#585b70"
        "--color=gutter:#313244"
      ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      config.global.hide_env_diff = true;
    };

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
