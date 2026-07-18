{ inputs, den, lib, ... }:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.aarch64-darwin.aspen.users.ivy = { };
  den.hosts.x86_64-linux.elm.users.ivy = { };

  # aspen keeps using `inputs.nix-darwin.lib.darwinSystem` directly — the
  # input is named `nix-darwin` here, not Den's default `darwin`.
  den.hosts.aarch64-darwin.aspen.instantiate = inputs.nix-darwin.lib.darwinSystem;

  # elm stays pinned to nixpkgs-stable / home-manager-stable to match its
  # NixOS release (see README's "Inputs of note").
  den.hosts.x86_64-linux.elm.instantiate = inputs.nixpkgs-stable.lib.nixosSystem;
  den.hosts.x86_64-linux.elm.home-manager.module = inputs.home-manager-stable.nixosModules.home-manager;

  # Home Manager OS-level flags, identical on both hosts.
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

  # set once, don't bump casually — was duplicated identically on both hosts.
  den.default.homeManager.home.stateVersion = "25.11";

  # Shared user wiring for ivy on both hosts. define-user/primary-user are
  # parametric on { host, user } so they resolve per-platform: OS user +
  # home.username/homeDirectory everywhere, wheel/networkmanager on NixOS,
  # system.primaryUser on Darwin.
  den.aspects.ivy.includes = [
    den.batteries.define-user
    den.batteries.primary-user
  ];
}
