# Fonts + GTK/QT theming for the two GUI desktops (aspen, alder). Fonts are
# cross-platform (darwin + nixos classes), while the GTK/QT bits below are
# Linux-only — aspen includes this same aspect but, being darwin, only ever
# picks up the darwin-class (fonts) half.
{
  den.aspects.theme.darwin = {pkgs, ...}: {
    fonts.packages = with pkgs; [ibm-plex aporetic];
  };

  den.aspects.theme.nixos = {pkgs, ...}: {
    fonts.packages = with pkgs; [ibm-plex aporetic];

    environment.systemPackages = with pkgs; [
      adw-gtk3
      nwg-look
      qt6Packages.qt6ct
    ];

    qt = {
      # enable qt and set its theme to null,
      # as we're using qt6ct to control that.
      enable = true;
      platformTheme = null;
    };

    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };
}
