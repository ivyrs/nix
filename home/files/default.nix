{
  isDarwin ? false,
  lib,
  ...
}:

{
  imports = [
    ./yazi.nix
    ./syncthing.nix
    ./documents.nix
    ./viewers.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./mimeapps.nix
    ./anki.nix
    ./nextcloud-client.nix
    ./zathura.nix
  ];
}
