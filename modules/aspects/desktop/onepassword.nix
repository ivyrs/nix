{...}: {
  den.aspects.onepassword.nixos = {...}: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["ivy"];
    };
  };

  den.aspects.onepassword.homeManager = {
    # 1Password's SSH agent only starts listening on this socket once it's
    # turned on inside the app itself (Settings > Developer > "Use the SSH
    # agent") — that toggle lives in 1Password's own encrypted settings, not
    # exposed as a NixOS/home-manager option, so it has to be flipped by hand
    # after first sign-in.
    programs.ssh = {
      enable = true;
      extraConfig = ''
        IdentityAgent ~/.1password/agent.sock
      '';
    };
  };
}
