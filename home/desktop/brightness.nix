{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "desktop-brightness";
      runtimeInputs = [ pkgs.brightnessctl ];
      text = builtins.readFile ./brightness.sh;
    })
  ];
}
