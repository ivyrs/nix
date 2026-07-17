{
  flake.modules.homeManager.base = {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
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
  };
}
