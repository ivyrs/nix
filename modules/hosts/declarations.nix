{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.den.flakeModule];

  den.schema.user.classes = lib.mkDefault ["homeManager"];

  # Home Manager OS-level flags, identical on every host.
  den.default.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "before-hm";
  };
  den.default.darwin.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "before-hm";
  };

  # set once, don't bump casually — was duplicated identically on every host.
  den.default.homeManager.home.stateVersion = "25.11";
}
