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
      # den.aspects.mango # disabled for now
      den.aspects.noctalia
      den.aspects.syncthing-client
      den.aspects.onepassword
      den.aspects.keepassxc
      den.aspects.gpg
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

      # alder-only: syncs den.aspects.keepassxc's database with elm (versioned
      # backup/history copy, same as obsidian) — not part of
      # den.aspects.syncthing-client itself. Same Syncthing folder ID as the
      # old pass-store tree used (kept as-is so elm's side doesn't need
      # re-pairing) — just repointed at the directory holding the .kdbx now.
      services.syncthing.settings.folders."password-store" = {
        id = st.passwordStoreFolderId;
        path = "${config.home.homeDirectory}/.keepass";
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

      # alder-only cutover from 1Password's SSH agent to KeePassXC's own SSH
      # Agent (den.aspects.keepassxc, modules/aspects/core/keepassxc.nix).
      # TODO(manual): this path needs to match whatever KeePassXC's SSH
      # Agent settings (Tools > Settings > SSH Agent) actually expose on
      # Linux once set up by hand — treat this as a starting point to
      # confirm/adjust, not a verified value. mkForce because
      # onepassword.nix's homeManager aspect (still included above) sets
      # extraConfig too — types.lines would otherwise concatenate both
      # IdentityAgent lines.
      programs.ssh.extraConfig = lib.mkForce "IdentityAgent ~/.cache/keepassxc/ssh-agent.sock";

      # alder's signing key now lives in KeePassXC's SSH Agent as a plain
      # OpenSSH keypair (the "alder" entry). git.nix only wires up
      # 1Password's op-ssh-sign for isDarwin, so this stays additive here,
      # not an override.
      programs.git.settings = {
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNudbGaj76Gu5Kn9bKsTCb8cAMPM0lg/hS6TriaWY7";
        commit.gpgsign = true;
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
        };
      };

      home.file.".ssh/allowed_signers".text =
        "ivy@ivy.rs ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNudbGaj76Gu5Kn9bKsTCb8cAMPM0lg/hS6TriaWY7\n";
    };
  };
}
