{
  den.aspects.core.homeManager = {
    programs.home-manager.enable = true;

    # We only use zsh integrations; don't let per-tool defaults follow this
    # global toggle into shells (bash/fish/nushell) we don't configure.
    home.shell.enableShellIntegration = false;

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      # Pin this so `sops` finds the personal key the same way on both
      # macOS and Linux, instead of relying on each OS's default config dir.
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };

    home.sessionPath = [
      "$HOME/.bin"
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };
}
