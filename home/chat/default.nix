{
  isDarwin ? false,
  lib,
  ...
}:

{
  imports = [
    ./vesktop.nix
    ./signal.nix
  ]
  ++ lib.optionals (!isDarwin) [
    ./xmpp.nix
    ./irc.nix
  ];
}
