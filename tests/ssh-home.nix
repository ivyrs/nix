# Run with: nix eval --impure --json --file tests/ssh-home.nix
let
  flake = builtins.getFlake (toString ../.);
  home = flake.homeConfigurations."ivy@ssh";
  config = home.config;
in
assert config.home.username == "ivy";
assert config.home.homeDirectory == "/home/ivy";
assert config.home.stateVersion == "26.05";
assert home.pkgs.stdenv.hostPlatform.system == "x86_64-linux";
assert config.programs.home-manager.enable;
assert config.programs.zsh.enable;
assert config.programs.git.enable;
assert config.programs.git.package == home.pkgs.git;
assert config.programs.tmux.enable;
assert config.programs.nvf.enable;
assert !config.ivy.git.signing.enable;
assert !(config.wayland.windowManager.niri.enable or false);
assert !config.services.mako.enable;
assert !config.services.swayidle.enable;
assert config.systemd.user.services == { };
assert config.systemd.user.sockets == { };
assert config.systemd.user.timers == { };
{
  activation = home.activationPackage.drvPath;
  sshOnly = true;
}
