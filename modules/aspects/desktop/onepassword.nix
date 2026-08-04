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
    # 1Password's SSH agent only listens on this socket once toggled on in
    # the app itself (Settings > Developer > "Use the SSH agent") — not a
    # NixOS/home-manager option, so flip it by hand after first sign-in.
    programs.ssh = {
      enable = true;
      # enableDefaultConfig is going away upstream; settings."*" below is a
      # verbatim copy of its current injected values, pinned so behavior
      # doesn't change when it's removed. Also required as of this
      # home-manager version: extraConfig asserts settings."*" is declared.
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
      extraConfig = ''
        IdentityAgent ~/.1password/agent.sock
      '';
    };
  };
}
