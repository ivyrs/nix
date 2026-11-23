# Run with nix eval --impure --json --file tests/prism-equivalence.nix --apply 'check: check { host = "alder"; }'
{ host }:
let
  flake = builtins.getFlake (toString ../.);
  inputs = flake.inputs // {
    self = flake;
  };
  isDarwin = host == "aspen";
  isInstaller = host == "installer";
  metadata =
    if isDarwin then
      flake.metadata
      // {
        user = flake.metadata.user // {
          homeDirectory = "/Users/${flake.metadata.user.username}";
        };
      }
    else
      flake.metadata;
  platform = if isInstaller then "x86_64-linux" else metadata.hosts.${host}.system;
  constructor =
    if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
  family = if isDarwin then "darwin" else "nixos";
  legacy = constructor {
    system = platform;
    specialArgs = { inherit inputs metadata; };
    modules = [ (flake.outPath + "/hosts/${family}/${host}") ];
  };
  migrated =
    if isDarwin then flake.darwinConfigurations.${host} else flake.nixosConfigurations.${host};
  inspect =
    system:
    let
      config = system.config;
      home = config.home-manager.users.${metadata.user.username};
    in
    {
      system = if isDarwin then system.system.drvPath else config.system.build.toplevel.drvPath;
      platform = system.pkgs.stdenv.hostPlatform.system;
      stateVersion = config.system.stateVersion;
    }
    // inputs.nixpkgs.lib.optionalAttrs (!isInstaller) {
      home = home.home.activationPackage.drvPath;
      homeDirectory = home.home.homeDirectory;
      homeStateVersion = home.home.stateVersion;
      hermesProgramDeclared = home.programs ? hermes-agent;
      hermesDesktopEnabled = home.programs.hermes-agent.desktop.enable or false;
      hermesServicesEnabled = home.services.hermes-agent.enable or false;
      hermesUnits = builtins.filter (name: builtins.match ".*hermes.*" name != null) (
        builtins.attrNames home.systemd.user.services
      );
    };
  result = inspect migrated;
in
assert
  builtins.attrNames flake.nixosConfigurations == [
    "alder"
    "installer"
    "maple"
  ];
assert builtins.attrNames flake.darwinConfigurations == [ "aspen" ];
assert inspect legacy == result;
assert result.platform == platform;
assert
  isInstaller
  || (
    (!result.hermesProgramDeclared || result.hermesDesktopEnabled)
    && !result.hermesServicesEnabled
    && result.hermesUnits == [ ]
  );
{
  inherit host result;
  equivalent = true;
}
