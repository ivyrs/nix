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
    # of the catppuccin-mocha default, then generate it dynamically at runtime.
    programs.aerc.extraConfig.ui.styleset-name = lib.mkForce "noctalia";

    # Generate noctalia aerc styleset dynamically by extracting colors from
    # noctalia's generated ghostty theme file. This follows the same pattern
    # as other apps that need noctalia theming but don't have official
    # template support yet.
    home.activation.aercNoctaliaStyleset = lib.hm.dag.entryAfter ["writeBoundary"] ''
      aercStylesetFile="$HOME/.config/aerc/stylesets/noctalia"
      ghosttyThemeFile="$HOME/.config/ghostty/themes/noctalia"
      
      mkdir -p "$(dirname "$aercStylesetFile")"
      
      # Wait for ghostty theme to be generated (other noctalia templates run first)
      if [ -f "$ghosttyThemeFile" ]; then
        # Extract colors from ghostty theme file
        bg=$(${lib.getExe pkgs.gnugrep} '^background = ' "$ghosttyThemeFile" | cut -d' ' -f3)
        fg=$(${lib.getExe pkgs.gnugrep} '^foreground = ' "$ghosttyThemeFile" | cut -d' ' -f3)
        selection_bg=$(${lib.getExe pkgs.gnugrep} '^selection-background = ' "$ghosttyThemeFile" | cut -d' ' -f3)
        selection_fg=$(${lib.getExe pkgs.gnugrep} '^selection-foreground = ' "$ghosttyThemeFile" | cut -d' ' -f3)
        # Primary teal (palette 2/10)
        primary=$(${lib.getExe pkgs.gnugrep} '^palette = 2=' "$ghosttyThemeFile" | cut -d'=' -f3)
        # Blue (palette 4/12)
        secondary=$(${lib.getExe pkgs.gnugrep} '^palette = 4=' "$ghosttyThemeFile" | cut -d'=' -f3)
        # Red (palette 1/9)
        error_color=$(${lib.getExe pkgs.gnugrep} '^palette = 1=' "$ghosttyThemeFile" | cut -d'=' -f3)
        # Muted colors (palette 8)
        muted=$(${lib.getExe pkgs.gnugrep} '^palette = 8=' "$ghosttyThemeFile" | cut -d'=' -f3)
        
        # Generate aerc styleset with noctalia colors
        cat > "$aercStylesetFile" << EOF
# Generated noctalia theme for aerc, based on colors from ghostty theme
*.default=true
*.normal=true

default.fg=$fg

error.fg=$error_color
warning.fg=$secondary  
success.fg=$primary

tab.fg=$muted
tab.bg=$bg
tab.selected.fg=$fg
tab.selected.bg=$selection_bg
tab.selected.bold=true

border.fg=$muted
border.bold=true

msglist_unread.bold=true
msglist_flagged.fg=$secondary
msglist_flagged.bold=true
msglist_result.fg=$primary
msglist_result.bold=true
msglist_*.selected.bold=true
msglist_*.selected.bg=$selection_bg
msglist_*.selected.fg=$selection_fg
msglist_deleted.fg=$muted

dirlist_*.selected.bold=true
dirlist_*.selected.bg=$selection_bg
dirlist_*.selected.fg=$selection_fg

statusline_default.fg=$muted
statusline_default.bg=$selection_bg
statusline_error.fg=$error_color
statusline_error.bold=true
statusline_success.bold=true

completion_default.selected.bg=$selection_bg
completion_description.dim=true

part_filename.selected.fg=$selection_fg
part_filename.selected.bg=$selection_bg
part_switcher.selected.bg=$selection_bg

part_mimetype.selected.fg=$selection_fg
part_mimetype.selected.bg=$selection_bg

selector_focused.bold=true
selector_focused.bg=$selection_bg
selector_focused.fg=$selection_fg

[viewer]
url.fg=$primary
url.underline=true
header.bold=true
signature.dim=true
diff_meta.bold=true
diff_chunk.fg=$secondary
diff_chunk_func.fg=$secondary
diff_chunk_func.bold=true
diff_add.fg=$primary
diff_del.fg=$error_color
quote_1.fg=$primary
quote_2.fg=$secondary
quote_3.fg=$muted
quote_4.fg=$selection_fg
quote_x.fg=$muted
EOF
      else
        # Fallback: create empty file if ghostty theme not available yet
        echo "# Noctalia theme not yet generated" > "$aercStylesetFile"
      fi
    '';

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
      settings = ./noctalia-settings.toml;
    };
  };
}
