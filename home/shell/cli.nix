{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    ripgrep
    bat
    fd
    jq
    eza
    duf
    btop
    dust
    procs
    sd
    just
    ripgrep-all
    tokei
    hyperfine
    xh
    mprocs
    kondo
    gh
    sops
    age
    ssh-to-age
    glow
    devenv
    rustup
  ];

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = lib.mkDefault [
      "--style=minimal"
      "--info=inline-right"
      "--highlight-line"
      "--no-separator"
      "--color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8,fg+:#cdd6f4,bg+:#313244"
      "--color=hl+:#f38ba8,info:#cba6f7,prompt:#cba6f7,pointer:#f5e0dc"
      "--color=marker:#f8ebe8,spinner:#f5e0dc,header:#f38ba8,border:#585b70"
      "--color=gutter:#313244"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    # No sync server since Yew was decommissioned; local history only
    # until a replacement exists.
    settings = {
      auto_sync = false;

      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    #enableNushellIntegration = true;
    config.global.hide_env_diff = true;
  };

  programs.zsh = {
    initContent = ''
      eval "$(devenv hook zsh)"
    '';
  };

}
