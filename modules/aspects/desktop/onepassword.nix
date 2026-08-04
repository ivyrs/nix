{...}: {
  den.aspects.onepassword.nixos = {...}: {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = ["ivy"];
    };
  };

  # nix-darwin has no equivalent programs._1password{,-gui} module (no
  # systemd/polkit to integrate with there), so Darwin just gets the raw
  # packages — the GUI app handles its own permissions prompts on first launch.
  den.aspects.onepassword.darwin = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [_1password-gui _1password-cli];
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
