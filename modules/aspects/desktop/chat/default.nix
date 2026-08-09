# Terminal chat clients, cross-platform via nixpkgs (aspen + alder both
# build these fine — no homebrew-cask split needed like productivity/).
{
  den.aspects.desktop.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [
        profanity # XMPP — no home-manager module, config lives in-app
      ]
      ++ [
        # Telegram + WhatsApp + Signal — no home-manager module, config lives
        # in-app. Signal support (nchat-signal, see packages/nchat-signal) is
        # Linux-only: it's only been built/tested on alder, and libsignal-ffi
        # needs xcodebuild on Darwin which is untested here — aspen keeps
        # plain nixpkgs nchat (Telegram + WhatsApp) until that's verified.
        (
          if lib.strings.hasSuffix "linux" pkgs.stdenv.hostPlatform.system
          then pkgs.callPackage ../../../../packages/nchat-signal/default.nix {}
          else nchat
        )
      ];

    # Matrix. Not gomuks: nixpkgs' gomuks-0.3.1 still links the deprecated,
    # CVE-flagged libolm. iamb is on matrix-rust-sdk/vodozemac instead.
    # No password baked in — iamb stores its session after an in-app
    # /login, so there's no credential to wire through sops here. The
    # profile stanza itself (user_id + url) is required by iamb even so;
    # `url` is set explicitly since the homeserver (matrix.skji.org) is on
    # a different domain than the user_id (skji.org).
    programs.iamb = {
      enable = true;
      settings = {
        profiles."skji.org" = {
          user_id = "@ivy:skji.org";
        };
        notifications.enabled = true;
        image_preview.protocol.type = "kitty";
      };
    };

    # IRC, via sourcehut's chat.sr.ht bouncer rather than a direct network
    # connection — see https://man.sr.ht/chat.sr.ht/quickstart.md. SASL
    # username is the sourcehut account name; the bouncer treats an OAuth
    # personal access token as the password. Per-network IRC config (which
    # upstream networks the bouncer joins) is set separately via
    # `/msg BouncerServ` or https://chat.sr.ht, not from here.
    programs.senpai = {
      enable = true;
      config = {
        address = "chat.sr.ht:6697";
        nickname = "ivyrose";
        username = "ivyrs";
        password-cmd = ["cat" "/run/secrets/senpai-srht-token"];
      };
    };
  };
}
