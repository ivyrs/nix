{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- hardware support
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/release-2026-07-30";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-x86-on-aarch64 = {
      url = "github:rowanG077/nix-x86-on-aarch64";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- macOS stuff
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # -- desktop stuff

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    # Helium browser (prebuilt upstream Linux release, repackaged for Nix)
    helium-browser = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    albedo.url = "git+https://tangled.org/okami.mom/albedo";
    hermes-agent.url = "github:NousResearch/hermes-agent";

    # Local development input; flake.lock pins the reviewed Lark checkpoint.
    # Replace with a published URL when this should work on other machines.
    lark.url = "git+file:///home/ivy/projects/code/lark?ref=main";

    # nokkvi.url = "github:f-o-o-g-s/nokkvi";

    nvf.url = "github:NotAShelf/nvf/v26.07";

    otter-launcher = {
      url = "github:kuokuo123/otter-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # -- flake plumbing

    prism = {
      url = "git+https://tangled.org/poacher.dev/prism";
      inputs.nixpkgs.follows = "nixpkgs";
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

    sops = {
      url = "github:Mic92/sops-nix";
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

      hostSystems = import ./prism { inherit inputs metadata aspenMetadata; };

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          programs.nixfmt.enable = true;
        }
      );
    in
    {
      inherit metadata;

      nixosConfigurations = {
        inherit (hostSystems) alder maple installer;
      };

      darwinConfigurations = {
        inherit (hostSystems) aspen;
      };

      homeModules = import ./home/exports.nix { inherit metadata; };

      packages = forAllSystems (
        system:
        import ./pkgs {
          inherit inputs;
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            just
            nil
          ];
        };
      });
    };
}
