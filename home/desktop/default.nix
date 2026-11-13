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
    ./brightness.nix
    ./lock.nix
    ./notifications.nix
    ./noctalia
    ./helium.nix
    ./otter
    ./fsel
  ];
}
