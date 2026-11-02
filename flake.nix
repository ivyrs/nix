{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    # Keep hosts on stable; use this only for packages with a concrete need.
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # --- hardware support
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2026-07-30";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-x86-on-aarch64 = {
      url = "github:rowanG077/nix-x86-on-aarch64";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- macOS stuff
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    umbriel.url = "github:noctalia-dev/umbriel/cachix";

    # terminal-based music player/library, pointed at Navidrome via the
    # subsonicsource plugin. Feeds the noctalia theme template in
    # home/desktop/noctalia.
    musikcube = {
      url = "github:ivyrs/musikcube2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helium browser (prebuilt upstream Linux release, repackaged for Nix)
    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NVF also builds plugins (including blink-cmp) with its own nixpkgs.
    nvf.url = "github:NotAShelf/nvf/v26.07";

    otter-launcher = {
      url = "github:kuokuo123/otter-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # format all the things
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      metadata = import ./metadata.nix;
      aspenMetadata = metadata // {
        user = metadata.user // {
          homeDirectory = "/Users/${metadata.user.username}";
        };
      };

      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkNixosHost =
        name:
        nixpkgs.lib.nixosSystem {
          system = metadata.hosts.${name}.system;
          specialArgs = { inherit inputs metadata; };
          modules = [ (./hosts/nixos + "/${name}") ];
        };

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          programs.nixfmt.enable = true;
        }
      );
    in
    {
      inherit metadata;

      nixosConfigurations =
        (nixpkgs.lib.genAttrs [
          "alder"
          "maple"
        ] mkNixosHost)
        // {
          installer = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs metadata; };
            modules = [ ./hosts/nixos/installer ];
          };
        };

      darwinConfigurations.aspen = inputs.nix-darwin.lib.darwinSystem {
        system = metadata.hosts.aspen.system;

        specialArgs = {
          inherit inputs;
          metadata = aspenMetadata;
        };

        modules = [
          ./hosts/darwin/aspen
        ];
      };

      homeModules = {
        shell = {
          imports = [ ./home/shell ];
          _module.args = { inherit metadata; };
        };
        tmux = ./home/shell/tmux;
        git = {
          imports = [ ./home/dev/git ];
          _module.args = { inherit metadata; };
        };

        nvim = ./home/dev/neovim/core.nix;
        nvim-full = ./home/dev/neovim;

        niri = ./home/desktop/niri;
        ghostty = ./home/desktop/ghostty.nix;
        noctalia = {
          imports = [ ./home/desktop/noctalia ];
          _module.args = { inherit metadata; };
        };

        default = {
          _module.args = { inherit metadata; };
          imports = [
            ./home/shell
            ./home/dev/git
            ./home/dev/neovim/core.nix
            ./home/shell/tmux
          ];
        };

        desktop = {
          _module.args = { inherit metadata; };
          imports = [
            ./home/desktop/niri
            ./home/desktop/noctalia
            ./home/desktop/ghostty.nix
          ];
        };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = self.packages.${system}.neovim;

          neovim =
            (inputs.nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [
                ./home/dev/neovim/config/core.nix
                ./home/dev/neovim/config/languages.nix
              ];
            }).neovim;

          neovim-core =
            (inputs.nvf.lib.neovimConfiguration {
              inherit pkgs;
              modules = [
                ./home/dev/neovim/config/core.nix
              ];
            }).neovim;
        }
      );

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              just
              nil
            ];
          };
        }
      );
    };
}
