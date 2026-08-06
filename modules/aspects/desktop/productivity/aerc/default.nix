# TUI mail client, workstation-only like the rest of desktop/default.nix.
# Talks to Fastmail directly over IMAP/SMTP — no local mail sync (mbsync)
# involved, so nothing to keep in step offline. Account definitions
# (address, credentials) live in ../email.nix; this file is just the
# client's own UI/filter config.
{
  den.aspects.desktop.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    # chafa renders image parts inline as terminal art (see the `filters`
    # block below) — aerc's own w3m-based html filter ships wrapped inside
    # its nix package already, so it needs no separate package here.
    home.packages = [pkgs.chafa];

    programs.aerc = {
      enable = true;

      extraConfig = {
        # accounts.conf lands in the nix store (world-readable), but no
        # credentials are written there since passwordCommand is used
        # instead of a literal password — so this is safe to set.
        general.unsafe-accounts-conf = true;
        general.mouse-enabled = true;

        # mkDefault: hosts without noctalia keep this Catppuccin fallback.
        # Hosts with noctalia override this to "noctalia" (see noctalia.nix)
        # to pick up the dynamically-generated styleset instead.
        ui.styleset-name = lib.mkDefault "catppuccin-mocha";

        # Filters pipe a part's bytes through a command and render its stdout
        # in the message pane (what `:view`/Enter uses). aerc's bundled
        # aerc.conf only seeds these as a one-time template if no real config
        # file exists yet; since `extraConfig` here means home-manager always
        # writes one, every default has to be repeated explicitly. These
        # mirror aerc's shipped defaults, plus our own image/* using chafa
        # instead of GUI Preview.
        filters = {
          "text/plain" = "colorize";
          "text/calendar" = "calendar";
          "message/delivery-status" = "colorize";
          "message/rfc822" = "colorize";
          "text/html" = "! html";
          ".headers" = "colorize";
          "image/*" = "chafa -f symbols";
        };

        # `:open` saves the part to a temp file and hands it to an external
        # command with no visible output, so only a real GUI app works. Plain
        # `open <tmpfile>` fails: Go's mime package resolves text/html to
        # ".ehtml" and image/jpeg to ".jfif", neither registered on macOS.
        # `-a <App>` opens by app instead of by extension, sidestepping that.
        openers = {
          "text/html" = "open -a Safari";
          "image/jpeg" = "open -a Preview";
        };
      };

      stylesets.catppuccin-mocha = builtins.readFile ./aerc-catppuccin-mocha.conf;
      # Placeholder for noctalia's dynamic theme. On noctalia hosts, this gets
      # overwritten by a home activation script (see noctalia.nix) with the
      # generated theme content. On non-noctalia hosts, this empty fallback
      # won't be used since ui.styleset-name defaults to "catppuccin-mocha".
      stylesets.noctalia = lib.mkDefault "";
    };
  };
}
