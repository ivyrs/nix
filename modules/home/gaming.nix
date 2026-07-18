{
  # Stub — not included on any host yet. Opt a host in via:
  #   den.aspects.<host>.provides.to-users.homeManager.imports = [ den.aspects.gaming.homeManager ];
  den.aspects.gaming.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ prismlauncher ];
  };
}
