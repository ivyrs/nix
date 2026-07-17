{
  flake.modules.homeManager.base = {
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
            "aspen.ocelot-perch.ts.net" = "aspen";
            "elm.ocelot-perch.ts.net" = "elm";
          };
          disabled = false;
        };
      };
    };
  };
}
