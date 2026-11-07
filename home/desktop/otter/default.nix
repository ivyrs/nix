{
  config,
  inputs,
  pkgs,
  ...
}:
let
  otter-launcher = inputs.otter-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ ./scripts/power-menu.nix ];

  xdg.configFile = {
    "otter-launcher/config.toml".source = ./config.toml;
    "foot/otter.ini".source = ./foot.ini;
  };

  home.packages = [
    otter-launcher
    pkgs.foot
    (pkgs.writeShellApplication {
      name = "otter-prompt";
      runtimeInputs = [ pkgs.foot ];
      text = ''
        exec foot --config="${config.xdg.configHome}/foot/otter.ini" \
          --app-id=rs.ivy.otter ${otter-launcher}/bin/otter-launcher
      '';
    })
    pkgs.wiremix
    pkgs.bluetui
    # nmrs-tui requires Rust 1.96; stable currently ships 1.95.
    (pkgs.callPackage ../../../pkgs/nmrs-tui.nix {
      inherit (inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}) rustPlatform;
    })
    pkgs.wdisplays
    (pkgs.writeShellApplication {
      name = "otter-battery";
      text = builtins.readFile ./scripts/battery.sh;
    })
    (pkgs.callPackage ../../../pkgs/lazytailscale.nix { })
    (pkgs.writeShellApplication {
      name = "tui";
      runtimeInputs = [
        pkgs.ghostty
        pkgs.util-linux
      ];
      text = ''
        setsid -f ghostty --gtk-single-instance=false --class=rs.ivy.tui -e "$@" >/dev/null 2>&1
      '';
    })
  ];
}
