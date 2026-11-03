{
  inputs,
  metadata,
  config,
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
      hermesEnvFile = config.sops.secrets.hermes-env.path;
    };

    backupFileExtension = "hm-backup";
  };
}
