{ metadata }:

{
  shell = {
    imports = [ ./shell ];
    _module.args = { inherit metadata; };
  };
  tmux = ./shell/tmux;
  git = {
    imports = [ ./dev/git ];
    _module.args = { inherit metadata; };
  };

  nvim = ./dev/neovim/core.nix;
  nvim-full = ./dev/neovim;

  niri = ./desktop/niri;
  ghostty = ./desktop/ghostty.nix;
  lock = ./desktop/lock.nix;
  notifications = ./desktop/notifications.nix;
  noctalia = {
    imports = [ ./desktop/noctalia ];
    _module.args = { inherit metadata; };
  };

  default = {
    _module.args = { inherit metadata; };
    imports = [
      ./shell
      ./dev/git
      ./dev/neovim/core.nix
      ./shell/tmux
    ];
  };

  desktop = {
    _module.args = { inherit metadata; };
    imports = [
      ./desktop/niri
      ./desktop/lock.nix
      ./desktop/notifications.nix
      ./desktop/noctalia
      ./desktop/ghostty.nix
    ];
  };
}
