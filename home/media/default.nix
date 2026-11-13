{ pkgs, ... }:

{
  imports = [ ./music.nix ];

  home.packages = [ pkgs.aseprite ];
}
