{
  flake.modules.homeManager.base = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "brew" "eza" ];
      };

      initContent = ''
        zstyle ':completion:*' menu select
      '';

      shellAliases = {
        e = "nvim";

        l = "eza";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        lsa = "eza -la";
        lt = "eza -T";
        lta = "eza -T -a";
        tree = "eza -T";

        cat = "bat";
        df = "duf";
        top = "btop";
        find = "fd";
        grep = "rg";
        du = "dust";
        ps = "procs";
        sed = "sd";
      };
    };
  };
}
