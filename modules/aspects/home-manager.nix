{den, ...}: {
  # The base home-manager environment every host gets, composed from the
  # individually-referenceable pieces below. Mirrors xela-nix's own
  # den.aspects.home-manager bundling aspect.
  den.aspects.home-manager.includes = [
    den.aspects.core
    den.aspects.packages
    den.aspects.shell
    den.aspects.git
    den.aspects.neovim
    den.aspects.tmux
  ];
}
