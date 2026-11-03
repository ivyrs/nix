{
  isDarwin ? false,
  lib,
  ...
}:

{
  imports = [
    ./ai.nix
    ./firefox.nix
    ./ghostty.nix
    ./peripherals.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./niri
    ./noctalia
    ./helium.nix
    ./new-shell
  ];
}
