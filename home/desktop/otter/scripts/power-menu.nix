{ config, pkgs, ... }:
let
  actions = pkgs.writeShellApplication {
    name = "power-menu-actions";
    runtimeInputs = [
      (pkgs.callPackage ../../../../pkgs/fsel.nix { })
      pkgs.niri
      pkgs.systemd
    ];
    text = builtins.readFile ./power-menu.sh;
  };
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "power-menu";
      runtimeInputs = [ pkgs.foot ];
      text = ''
        exec foot --config="${config.xdg.configHome}/foot/otter.ini" \
          --app-id=rs.ivy.power --override=initial-window-size-pixels=360x180 \
          ${actions}/bin/power-menu-actions
      '';
    })
  ];
}
