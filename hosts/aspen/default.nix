{
  config,
  den,
  inputs,
  ...
}: {
  den.hosts.aarch64-darwin.aspen.users.ivy = {};

  # aspen keeps using `inputs.nix-darwin.lib.darwinSystem` directly — the
  # input is named `nix-darwin` here, not Den's default `darwin`.
  den.hosts.aarch64-darwin.aspen.instantiate = inputs.nix-darwin.lib.darwinSystem;

  den.aspects.aspen = {
    includes = [
      den.batteries.hostname
      den.aspects.nix-settings
    ];

    darwin = {
      imports = [
        inputs.sops-nix.darwinModules.sops
        inputs.nix-homebrew.darwinModules.nix-homebrew
        config.flake.modules.darwin.homebrew
        config.flake.modules.darwin.sops
        config.flake.modules.darwin.aerospace
        config.flake.modules.darwin.system-defaults
        config.flake.modules.darwin.fonts
        config.flake.modules.darwin.touchid
        ({pkgs, ...}: {
          nixpkgs.hostPlatform = "aarch64-darwin";

          system.stateVersion = 6;
          system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

          networking.computerName = "aspen";
          networking.localHostName = "aspen";

          # Ghostty ships as the official signed build here; nixpkgs can't build it
          # from source on macOS yet.
          environment.systemPackages = with pkgs; [
            vim
            git
            ghostty-bin
            vesktop
            ice-bar
            _1password-gui
            _1password-cli
          ];

          programs.zsh.enable = true;

          # Remote Login (SSH). authorized_keys is managed via home-manager
          # (see hosts/aspen/home.nix) since nix-darwin's users.users module
          # has no openssh.authorizedKeys option, unlike NixOS's.
          services.openssh.enable = true;
        })
      ];
    };
  };
}
