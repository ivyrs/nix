{
  inputs,
  metadata,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs metadata;
      isDarwin = false;
    };

    backupFileExtension = "hm-backup";
  };
}
