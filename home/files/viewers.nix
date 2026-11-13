{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.mpv ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.imv ];
}
