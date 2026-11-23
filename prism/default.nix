{
  inputs,
  metadata,
  aspenMetadata,
}:
let
  # Prism supplies modules and specialArgs; keep platform selection explicit.
  mkNixosSystem = system: args: inputs.nixpkgs.lib.nixosSystem (args // { inherit system; });
in
inputs.prism.lib.mkSystems {
  specialArgs = { inherit inputs metadata; };
  modules = [ ./hosts.nix ];

  # Leaf tags only in this pass: shared policy stays in the existing modules.
  tags = _self: {
    alder = {
      build = true;
      mkSystem = mkNixosSystem metadata.hosts.alder.system;
    };
    maple = {
      build = true;
      mkSystem = mkNixosSystem metadata.hosts.maple.system;
    };
    installer = {
      build = true;
      mkSystem = mkNixosSystem "x86_64-linux";
    };
    aspen = {
      build = true;
      # Keep Darwin's host module at its original depth/order. A tag-section
      # wrapper reorders systemPackages relative to nix-darwin's defaults.
      extraModules = [ ../hosts/darwin/aspen ];
      mkSystem =
        args: inputs.nix-darwin.lib.darwinSystem (args // { system = metadata.hosts.aspen.system; });
      specialArgs.metadata = aspenMetadata;
    };
  };
}
