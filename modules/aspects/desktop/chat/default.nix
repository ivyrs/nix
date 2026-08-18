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

    # IRC, using self-hosted bouncer
    programs.senpai = {
      enable = true;
      config = {
        address = "bnc.ocelot-perch.ts.net:6698";
        nickname = "ivy";
        username = "ivy";
        password-cmd = ["cat" "/run/secrets/ivy-soju-pass"];
      };
    };
  };
}
