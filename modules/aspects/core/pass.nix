# Terminal-focused, fully open-source alternative to den.aspects.onepassword
# (modules/aspects/desktop/onepassword.nix): `pass` for secrets, gpg-agent's
# built-in ssh-agent emulation for SSH auth. Cut over on alder (see
# hosts/alder/home.nix's IdentityAgent/git signing overrides); aspen is still
# on 1Password. Moving secrets into the store (`pass insert ...`) and
# generating/importing a GPG key with an Authenticate-capable subkey are both
# manual, do-by-hand steps; nothing here does that for you.
{
  den.aspects.pass.homeManager = {pkgs, ...}: let
    passPackage = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
  in {
    programs.password-store = {
      enable = true;
      package = passPackage;
    };

    # `pf`: fzf over store entries, copies the selected one to the clipboard
    # via `pass -c` (which nixpkgs' pass wrapper already resolves through
    # xclip — works here because niri's xwayland-satellite bridges X11's
    # clipboard to Wayland's, see modules/aspects/desktop/niri/default.nix).
    home.packages = [
      (pkgs.writeShellApplication {
        name = "pf";
        runtimeInputs = [pkgs.fzf passPackage];
        text = ''
          store="''${PASSWORD_STORE_DIR:-$HOME/.password-store}"
          entry=$(find -L "$store" -type f -name '*.gpg' -not -path '*/.git/*' |
            sed -e "s|^$store/||" -e 's/\.gpg$//' |
            fzf --prompt='pass> ' --height=40% --reverse)
          [ -n "$entry" ] && pass -c "$entry"
        '';
      })
    ];

    programs.browserpass = {
      enable = true;
      browsers = ["firefox"];
    };

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      # curses over a GUI pinentry (pinentry-gnome3/-qt) to keep the
      # passphrase prompt in-terminal rather than popping a dialog.
      pinentry.package = pkgs.pinentry-curses;
      defaultCacheTtl = 600;
      maxCacheTtl = 28800; # 8h
    };

    # pinentry-curses draws into whichever tty invoked gpg; gpg-agent needs
    # to be told which one on each new shell (it doesn't track this itself).
    # The updatestartuptty call matters specifically for the ssh-agent path:
    # the ssh-agent protocol carries no concept of "which terminal asked", so
    # without this gpg-agent keeps trying to pinentry into whatever tty (or
    # none) was active when it was first started — failing with "Inappropriate
    # ioctl for device <Pinentry>" from any other shell.
    programs.zsh.initContent = ''
      export GPG_TTY=$(tty)
      gpg-connect-agent updatestartuptty /bye >/dev/null
    '';
  };
}
