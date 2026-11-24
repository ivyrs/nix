{ metadata, ... }:

{
  imports = [
    ../../../home/scripts
    ../../../home/desktop/nightlight.nix
    ../../../home/gaming
    ../../../home/media/lark.nix
  ];
  ivy.git.signing = {
    enable = true;
    key = metadata.user.sshKeys.alder;
  };
}
