# Terminal chat clients, cross-platform via nixpkgs (aspen + alder both
# build these fine — no homebrew-cask split needed like productivity/).
{
  # senpai's IRC password, used unconditionally below on both platforms.
  den.aspects.desktop.nixos.sops.secrets.ivy-soju-pass.owner = "ivy";
  den.aspects.desktop.darwin.sops.secrets.ivy-soju-pass.owner = "ivy";

  den.aspects.desktop.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [
        profanity # XMPP — no home-manager module, config lives in-app
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
