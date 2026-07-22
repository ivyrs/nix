# TUI mail client, workstation-only like the rest of workstation.nix.
# Talks to Fastmail directly over IMAP/SMTP — no local mail sync (mbsync)
# involved, so nothing to keep in step offline.
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.workstation.homeManager = {pkgs, ...}: {
    # chafa renders image parts inline as terminal art (see the `filters`
    # block below) — aerc's own w3m-based html filter ships wrapped inside
    # its nix package already, so it needs no separate package here.
    home.packages = [pkgs.chafa];

    accounts.email.accounts.ivy = {
      primary = true;
      address = meta.email;
      realName = "ivy forever";
      flavor = "fastmail.com";
      # Matches meta.smtp's port 587 (STARTTLS) instead of the flavor's
      # implicit-TLS 465 default.
      smtp.tls.useStartTls = true;
      # Fastmail app password, decrypted by sops-nix to /run/secrets on aspen
      # (see modules/sops.nix).
      passwordCommand = "cat /run/secrets/aerc-fastmail-password";

      aerc.enable = true;
    };

    programs.aerc = {
      enable = true;

      extraConfig = {
        # accounts.conf lands in the nix store (world-readable), but no
        # credentials are written there since passwordCommand is used
        # instead of a literal password — so this is safe to set.
        general.unsafe-accounts-conf = true;

        ui.styleset-name = "catppuccin-mocha";

        # Filters pipe a part's bytes through a command and render its
        # stdout right in the message pane — no external app, no new
        # window. This is what `:view`/Enter uses, and is the terminal-native
        # way to read mail here.
        #
        # aerc ships a bundled aerc.conf with its own [filters] (and
        # [openers]/[ui]/etc) defaults, but that's only ever used as a
        # one-time template copied in if `~/.config/aerc/aerc.conf` (here,
        # ~/Library/Preferences/aerc/aerc.conf) doesn't exist yet — once a
        # real file is there, aerc loads *only* that file, with no fallback
        # merge of the bundled section for anything left out. Since
        # `extraConfig` here means home-manager always writes a real
        # aerc.conf, every default we still want has to be repeated
        # explicitly. These mirror aerc's shipped defaults verbatim, plus
        # our own image/* entry using chafa instead of GUI Preview.
        filters = {
          "text/plain" = "colorize";
          "text/calendar" = "calendar";
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/html" = "! html";
          ".headers" = "colorize";
          "image/*" = "chafa -f symbols";
        };

        # `:open` (the `o`/`O` binds) is a different action from viewing: it
        # saves the part to a temp file and hands it to an external command,
        # whose output aerc never displays — so an interactive terminal
        # program run this way would produce no visible effect. A real GUI
        # app is the only thing that works here, and `-a <App>` is needed
        # over plain `open <tmpfile>`: Go's mime package resolves text/html
        # to the alphabetically-first known extension, ".ehtml", and
        # image/jpeg to ".jfif" — neither has a registered handler on macOS,
        # so `open` exits 1. `-a <App>` opens by app instead of by
        # extension, sidestepping that.
        openers = {
          "text/html" = "open -a Safari";
          "image/jpeg" = "open -a Preview";
        };
      };

      stylesets.catppuccin-mocha = builtins.readFile ./aerc-catppuccin-mocha.conf;
    };
  };
}
