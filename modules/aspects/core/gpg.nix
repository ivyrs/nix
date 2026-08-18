# GPG for PGP email only — split out of the old den.aspects.pass
# (modules/aspects/core/pass.nix, now modules/aspects/core/keepassxc.nix)
# during the KeePassXC migration so alder keeps signing/encrypting
# ivy@ivy.rs mail (productivity/aerc/default.nix's `pgp-provider = "gpg"`,
# productivity/email.nix's per-account `gpg` block, both gated on
# config.programs.gpg.enable) without pulling gpg-agent's SSH-agent role
# back in — that's KeePassXC's job now.
{
  den.aspects.gpg.homeManager = {pkgs, ...}: {
    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      # GUI pinentry rather than curses: pinentry-curses draws into whatever
      # tty GPG_TTY points at, not necessarily the calling process's own
      # stdio - a subprocess with no tty of its own (e.g. Claude Code's Bash
      # tool) still inherits GPG_TTY pointing at the real pts your terminal
      # is running on, so gpg-agent opens that device directly and can
      # corrupt whatever TUI (Claude Code's own renderer, lazygit's gocui
      # screen) is managing raw mode there. pinentry-gnome3 only needs the
      # Wayland socket, never the calling tty, which sidesteps this
      # entirely; niri floats it via the window-rule in
      # desktop/niri/ux.kdl instead of tiling it into the layout.
      pinentry.package = pkgs.pinentry-gnome3;
      defaultCacheTtl = 28800; # 8h
      maxCacheTtl = 86400; # 24h
    };
  };
}
