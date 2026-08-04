# nushell, available alongside zsh (zsh.nix) as an opt-in shell — not the
# login shell, which stays zsh (see modules/users/ivy.nix). Aliases mirror
# zsh.nix's where they translate directly; a few are left out because nu
# covers them natively (`cd ..`/`cd -`, `mkdir` always makes parent dirs).
{
  den.aspects.nu.homeManager.programs.nushell = {
    enable = true;

    settings.show_banner = false;

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

      c = "clear";
      reload = "exec nu";

      lg = "lazygit";

      # justfile shortcuts (see ./justfile at the flake root)
      j = "just";
      jsw = "just switch";
      jck = "just check";
      jfmt = "just fmt";
      jup = "just update";
      jdep = "just deploy";

      # nix maintenance
      nixgc = "nix-collect-garbage -d";
      nixgens = "nix-env --list-generations -p /nix/var/nix/profiles/system";

      ports = "lsof -i -P -n | rg LISTEN";
    };
  };
}
