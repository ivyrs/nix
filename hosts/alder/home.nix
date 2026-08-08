{
  den,
  config,
  ...
}: let
  # outer (flake) config, closed over here since the nested homeManager
  # function's own `config` argument below is the HM config, not this one —
  # see AGENTS.md's module-arg gotcha.
  st = config.flake.lib.meta.syncthing;
in {
  den.aspects.alder.provides.to-users = {
    includes = [
      den.aspects.home-manager
      den.aspects.ghostty
      den.aspects.desktop
      den.aspects.dev-tools
      den.aspects.emacs
      den.aspects.niri
      den.aspects.noctalia
      den.aspects.syncthing-client
      den.aspects.onepassword
      den.aspects.pass
      den.aspects.theme
      den.aspects.music
    ];

    homeManager = {
      config,
      lib,
      ...
    }: {
      # Auto-sync the calendars from modules/aspects/desktop/calendars.nix
      # every 5 min. This is a systemd user timer, Linux-only — aspen has no
      # systemd user session, so it stays a manual `vdirsyncer sync` there.
      services.vdirsyncer.enable = true;

      # alder-only: keep the obsidian vault under ~/text rather than the
      # ~/Documents/obsidian default from den.aspects.syncthing-client
      # (which aspen — a macOS host — still uses).
      services.syncthing.settings.folders.obsidian.path =
        lib.mkForce "${config.home.homeDirectory}/text/obsidian";

      # alder-only: syncs den.aspects.pass's store with elm (versioned
      # backup/history copy, same as obsidian) — not part of
      # den.aspects.syncthing-client itself since aspen has no GPG key to
      # decrypt any of it yet.
      services.syncthing.settings.folders."password-store" = {
        id = st.passwordStoreFolderId;
        path = "${config.home.homeDirectory}/.password-store";
        devices = ["elm"];
        ignorePerms = true;
        versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "2592000";
          };
        };
      };

      # alder-only cutover from 1Password's SSH agent to gpg-agent
      # (den.aspects.pass, modules/aspects/core/pass.nix): "SSH_AUTH_SOCK" is
      # OpenSSH's literal keyword for "use the env var" rather than a
      # hardcoded path, which home-manager's gpg-agent module already points
      # at the right socket. mkForce because onepassword.nix's homeManager
      # aspect (still included above, for aspen's sake) sets extraConfig too
      # — types.lines would otherwise concatenate both IdentityAgent lines.
      programs.ssh.extraConfig = lib.mkForce "IdentityAgent SSH_AUTH_SOCK";

      # Commit signing via the same key, over gpg-agent's ssh-agent
      # emulation — git.nix only wires up 1Password's op-ssh-sign for
      # isDarwin, so this is additive here, not an override.
      programs.git.settings = {
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjv1IJojqA/AjnhzIWBzvf/gqcg3zTEAJ0hwMKCcecK";
        commit.gpgsign = true;
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
      };

      home.file.".ssh/allowed_signers".text =
        "ivy@ivy.rs ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIjv1IJojqA/AjnhzIWBzvf/gqcg3zTEAJ0hwMKCcecK\n";
    };
  };
}
