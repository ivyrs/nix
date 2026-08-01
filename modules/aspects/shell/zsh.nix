{
  den.aspects.zsh.homeManager.programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "brew" "eza"];
    };

    initContent = ''
      zstyle ':completion:*' menu select

      if command -v devenv >/dev/null 2>&1; then
        eval "$(devenv hook zsh)"
      fi
    '';

    shellAliases = {
      e = "nvim";

      # base aliases from https://github.com/plttn/fish-eza
      l = "eza --group --header --group-directories-first";
      ls = "eza --group --header --group-directories-first";
      ll = "eza --group --header --group-directories-first --long --git";
      le = "eza --group --header --group-directories-first --extended --long";
      lt = "eza --group --header --group-directories-first --tree --level";
      lc = "eza --group --header --group-directories-first --across";
      lo = "eza --group --header --group-directories-first --oneline";

      la = "eza -la";
      lsa = "eza -la";
      lta = "eza -T -a";
      tree = "eza --group --header --group-directories-first --tree";

      cat = "bat";
      df = "duf";
      top = "btop";
      find = "fd";
      grep = "rg";
      du = "dust";
      ps = "procs";
      sed = "sd";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "-" = "cd -";

      c = "clear";
      mkdir = "mkdir -p";
      reload = "exec zsh";

      lg = "lazygit";

      # justfile shortcuts (see ./justfile at the flake root)
      jsw = "just switch";
      jck = "just check";
      jfmt = "just fmt";
      jup = "just update";
      jdep = "just deploy";

      # nix maintenance
      nixgc = "nix-collect-garbage -d";
      nixgens = "nix-env --list-generations -p /nix/var/nix/profiles/system";

      ports = "lsof -i -P -n | grep LISTEN";
    };
  };
}
