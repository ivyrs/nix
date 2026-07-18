{ config, den, inputs, ... }:
{
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
        ({ pkgs, ... }: {
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
        })
      ];
    };
  };
}
