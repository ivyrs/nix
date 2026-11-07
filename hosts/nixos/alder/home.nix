{ metadata, ... }:

{
  imports = [
    ../../../home/scripts
    ../../../home/desktop/nightlight.nix
  ];
  ivy.git.signing = {
    enable = true;
    key = metadata.user.sshKeys.alder;
  };
}
