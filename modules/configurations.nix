{ config, inputs, self, ... }:
{
  flake.darwinConfigurations.aspen = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs self; };
    modules = [
      config.flake.modules.darwin.aspen
      inputs.sops-nix.darwinModules.sops
      inputs.nix-homebrew.darwinModules.nix-homebrew
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
	home-manager.backupFileExtension = "before-hm";

        home-manager.users.ivy.imports = [
          inputs.nvf.homeManagerModules.default
          config.flake.modules.homeManager.base
          config.flake.modules.homeManager.aspen
          config.flake.modules.homeManager.syncthing
        ];
      }
    ];
  };

  flake.homeConfigurations.aspen = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    extraSpecialArgs = { inherit inputs self; };
    modules = [
      inputs.nvf.homeManagerModules.default
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.aspen
      config.flake.modules.homeManager.syncthing
    ];
  };

  flake.homeConfigurations.elm = inputs.home-manager-stable.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = { inherit inputs self; };
    modules = [
      inputs.nvf.homeManagerModules.default
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.elm
    ];
  };

  flake.nixosConfigurations.elm = inputs.nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";   # confirm this matches elm's real arch
    specialArgs = { inherit inputs self; };
    modules = [
      config.flake.modules.nixos.elm
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager-stable.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
	home-manager.backupFileExtension = "before-hm";

        home-manager.users.ivy.imports = [
          inputs.nvf.homeManagerModules.default
          config.flake.modules.homeManager.base
          config.flake.modules.homeManager.elm
        ];
      }
    ];
  };
}
