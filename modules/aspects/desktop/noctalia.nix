{inputs, ...}: {
  # noctalia is a Quickshell-based Wayland shell/bar for niri, replacing
  # waybar. See https://docs.noctalia.dev/v5/getting-started/installation/
  # (NixOS-specific steps: https://docs.noctalia.dev/v5/getting-started/nixos/)
  den.aspects.noctalia.nixos = {
    imports = [inputs.noctalia.nixosModules.default];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      # Wires up NetworkManager, Bluetooth, UPower, and power-profiles-daemon,
      # which noctalia's wifi/bluetooth/power-profile/battery widgets need.
      recommendedServices.enable = true;
    };
  };

  den.aspects.noctalia.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.noctalia.homeModules.default];

    # Forcing empty settings keeps config.yml a mutable dotfile (home-manager
    # only symlinks it when non-empty, see git.nix) so noctalia's lazygit
    # template can write its theme at runtime instead of hitting a read-only
    # nix-store symlink. Means git.nix's os.editPreset/pagers/gui defaults
    # don't apply here — re-add by hand in config.yml if wanted.
    programs.lazygit.settings = lib.mkForce {};

    # See ghostty.nix: only noctalia hosts actually render a "noctalia"
    # ghostty theme file, so only they should reference it.
    programs.ghostty.settings.theme = lib.mkForce "noctalia";

    # See zathura.nix: noctalia writes its generated theme independently to
    # ~/.config/zathura/noctaliarc (a sibling file, not the home-manager-
    # managed zathurarc itself, so no read-only-symlink clash like
    # ghostty/lazygit have). `include` pulls it in; options must be forced
    # empty or zathura.nix's static Catppuccin `set` lines would be written
    # after the include and win.
    programs.zathura.options = lib.mkForce {};
    programs.zathura.extraConfig = "include noctaliarc";

    # See aerc/default.nix: force aerc to use the "noctalia" styleset instead
    # of the catppuccin-mocha default, then generate it dynamically at runtime
    # using noctalia's user template system.
    programs.aerc.extraConfig.ui.styleset-name = lib.mkForce "noctalia";

    # See integrations.nix: force fzf to minimal options, then source the
    # noctalia-generated color configuration
    programs.fzf.defaultOptions = lib.mkForce [
      "--style=minimal"
      "--info=inline-right"
      "--highlight-line"
      "--no-separator"
    ];

    # Source noctalia fzf colors via shell initialization
    home.sessionVariablesExtra = ''
      [ -f "$HOME/.config/fzf/noctalia-colors.sh" ] && source "$HOME/.config/fzf/noctalia-colors.sh"
    '';

    # See tmux/default.nix: override tmux config to source noctalia theme
    programs.tmux.extraConfig = lib.mkForce ''
      ${builtins.readFile ../dev/tmux/tmux.conf}

      # Source noctalia-generated theme (will override hardcoded colors above)
      source-file -q ~/.config/tmux/noctalia-theme.conf
    '';

    # Provide template files for noctalia's user template system
    home.file.".config/noctalia/templates/aerc.conf".source = ./noctalia-aerc-template.conf;
    home.file.".config/noctalia/templates/fzf.sh".source = ./noctalia-fzf-template.sh;
    home.file.".config/noctalia/templates/tmux.conf".source = ./noctalia-tmux-template.conf;

    # "dark-ansi" makes Claude Code render via the terminal's own 16-color
    # ANSI palette instead of its "dark" preset's fixed hex colors, so it
    # follows ghostty's dynamically-generated "noctalia" theme too. Merged
    # with jq (not a static home.file) since settings.json also holds
    # permissions/MCP config we don't own.
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
      # Merges as a background default under the live settings.toml (which
      # always wins key-for-key), so this seeds a fresh install without
      # fighting tweaks made through noctalia's own settings UI.
      settings = lib.mkMerge [
        (builtins.fromTOML (builtins.readFile ./noctalia-settings.toml))
        {
          # Add user templates to enable noctalia theming for apps without
          # community templates
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
        }
      ];
    };
  };
}
