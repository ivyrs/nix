{inputs, ...}: {
  den.aspects.noctalia.nixos = {
    imports = [inputs.noctalia.nixosModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      recommendedServices.enable = true;
    };
  };

  den.aspects.noctalia.homeManager = {
    lib,
    pkgs,
    ...
  }: { 
    imports = [inputs.noctalia.homeModules.default];

    home.packages = [pkgs.swappy];

    programs.lazygit.settings = lib.mkForce {};

    programs.ghostty.settings.theme = lib.mkForce "noctalia";

    programs.zathura.options = lib.mkForce {};
    programs.zathura.extraConfig = "include noctaliarc";

    programs.aerc.extraConfig.ui.styleset-name = lib.mkForce "noctalia";

    programs.fzf.defaultOptions = lib.mkForce [
      "--style=minimal"
      "--info=inline-right"
      "--highlight-line"
      "--no-separator"
    ];

    home.sessionVariablesExtra = ''
      [ -f "$HOME/.config/fzf/noctalia-colors.sh" ] && source "$HOME/.config/fzf/noctalia-colors.sh"
    '';

    programs.tmux.extraConfig = lib.mkForce ''
      ${builtins.readFile ../../../dev/tmux/tmux.conf}

      # Source noctalia-generated theme (will override hardcoded colors above)
      source-file -q ~/.config/tmux/noctalia-theme.conf
    '';

    home.file.".config/noctalia/templates/aerc.conf".source = ./templates/aerc.conf;
    home.file.".config/noctalia/templates/fzf.sh".source = ./templates/fzf.sh;
    home.file.".config/noctalia/templates/tmux.conf".source = ./templates/tmux.conf;

    home.activation.claudeCodeNoctaliaTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settingsFile="$HOME/.claude/settings.json"
      mkdir -p "$(dirname "$settingsFile")"
      [ -f "$settingsFile" ] || echo '{}' > "$settingsFile"
      ${lib.getExe pkgs.jq} '.theme = "dark-ansi"' "$settingsFile" > "$settingsFile.tmp"
      mv "$settingsFile.tmp" "$settingsFile"
    '';

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = lib.mkMerge [
        (builtins.fromTOML (builtins.readFile ./settings.toml))
        {
          theme.templates.user.aerc = {
            input_path = "$XDG_CONFIG_HOME/noctalia/templates/aerc.conf";
            output_path = "$XDG_CONFIG_HOME/aerc/stylesets/noctalia";
          };
          theme.templates.user.fzf = {
            input_path = "$XDG_CONFIG_HOME/noctalia/templates/fzf.sh";
            output_path = "$XDG_CONFIG_HOME/fzf/noctalia-colors.sh";
          };
          theme.templates.user.tmux = {
            input_path = "$XDG_CONFIG_HOME/noctalia/templates/tmux.conf";
            output_path = "$XDG_CONFIG_HOME/tmux/noctalia-theme.conf";
          };
          shell.screenshot.pipe_command = "swappy -f -";
        }
      ];
    };
  };
}
