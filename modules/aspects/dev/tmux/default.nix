{
  den.aspects.tmux.homeManager = {
    lib,
    ...
  }: {
    programs.tmux = {
      enable = true;
      extraConfig = lib.mkMerge [
        (builtins.readFile ./tmux.conf)
        # mkDefault: non-noctalia hosts use the static config above.
        # Noctalia hosts get this overridden to source the dynamic theme.
        (lib.mkDefault "")
      ];
    };
  };
}
