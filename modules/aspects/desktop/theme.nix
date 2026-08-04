{den, ...}: {
  # stuff to theme linux desktop hosts with.
  den.aspects.theme.includes = [den.aspects.fonts];

  den.aspects.theme.nixos = {pkgs, ...}: {
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
