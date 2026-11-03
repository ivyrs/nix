{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  ncspot = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ncspot;
in
{
  home.packages = [
    ncspot
    pkgs.feishin
    pkgs.musikcube
  ]
  ++ lib.optionals isLinux [
    pkgs.playerctl
    inputs.nokkvi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Musikcube navigation and playback keys.
  home.file.".config/musikcube/hotkeys.json" = {
    text = builtins.toJSON {
      key_up = "k";
      key_down = "j";
      key_left = "h";
      key_right = "l";
      key_page_up = "^B";
      key_page_down = "^F";
      key_home = "g";
      key_end = "G";

      # Keep the media controls reachable after j/k/l become navigation keys.
      playback_previous = "H";
      playback_next = "L";
      playback_volume_up = "+";
      playback_volume_down = "-";

      # ^F is used for page down above.
      browse_category_filter = "M-f";
    };
    force = true;
  };
}
