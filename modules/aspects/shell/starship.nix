{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.starship.homeManager.programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    settings = {
      format = " $username$hostname$directory$character";
      right_format = "$all";

      # directory.style removed - let noctalia's starship template handle theming

      # character colors removed - let noctalia's starship template handle theming
      character = {
        success_symbol = ">";
        error_symbol = ">";
        vimcmd_symbol = "<";
      };

      git_branch = {
        format = "[$branch]($style)";
        # style removed - let noctalia handle theming
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
        # style removed - let noctalia handle theming
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        # style removed - let noctalia handle theming
      };

      username = {
        # style_user removed - let noctalia handle theming
        format = "[$user]($style)[@](white)";
        disabled = false;
      };

      hostname = {
        ssh_symbol = " ssh";
        # format colors removed - let noctalia handle theming
        format = "[$hostname]($style)[$ssh_symbol](bold blue) ";
        trim_at = ".";
        aliases = {
          "aspen.${meta.tailnet}" = "aspen";
          "elm.${meta.tailnet}" = "elm";
        };
        disabled = false;
      };
    };
  };
}
