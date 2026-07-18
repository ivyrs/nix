{ config, den, inputs, ... }:
{
  den.aspects.aspen = {
    includes = [ den.batteries.hostname ];

    darwin = {
      imports = [
        inputs.sops-nix.darwinModules.sops
        inputs.nix-homebrew.darwinModules.nix-homebrew
        config.flake.modules.darwin.homebrew
        config.flake.modules.darwin.sops
        ({ pkgs, ... }: {
          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.config.allowUnfree = true;

          # Keep the system on Lix — nix-darwin would otherwise swap in upstream Nix.
          nix.package = pkgs.lix;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # Weekly GC + store optimisation.
          nix.gc.automatic = true;
          nix.gc.interval = { Weekday = 0; Hour = 3; Minute = 0; };
          nix.gc.options = "--delete-older-than 30d";
          nix.optimise.automatic = true;

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

          system.defaults = {
            dock = {
              autohide = true;
              mru-spaces = false;
              show-recents = false;
              persistent-apps = [
                { app = "/Applications/Nix Apps/Ghostty.app"; }
                { app = "/Applications/Helium.app"; }
              ];
            };
            finder = {
              AppleShowAllExtensions = true;
              CreateDesktop = false;
              FXEnableExtensionChangeWarning = false;
              FXPreferredViewStyle = "clmv";
              ShowPathbar = true;
            };
          };

          # Fonts installed here are visible to GUI apps like Ghostty.
          fonts.packages = with pkgs; [ ibm-plex ];

          programs.zsh.enable = true;
          security.pam.services.sudo_local.touchIdAuth = true;
        })
      ];
    };
  };
}
