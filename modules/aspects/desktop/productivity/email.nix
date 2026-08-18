# Email account definitions (home-manager's `accounts.email` module),
# consumed by aerc via each account's `aerc.enable = true` — kept separate
# from productivity/aerc/default.nix so the account data (address,
# credentials) isn't tangled with the aerc client's own UI/filter config.
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.desktop.homeManager = {
    config,
    lib,
    ...
  }: {
    accounts.email.accounts.ivy = {
      primary = true;
      address = meta.email;
      realName = "ivy forever";
      flavor = "fastmail.com";
      # Matches meta.smtp's port 587 (STARTTLS) instead of the flavor's
      # implicit-TLS 465 default.
      smtp.tls.useStartTls = true;
      # Fastmail app password, decrypted by sops-nix to /run/secrets (see
      # modules/sops.nix).
      passwordCommand = "cat /run/secrets/aerc-fastmail-password";

      # Matches Fastmail's actual folder names.
      folders = {
        inbox = "INBOX";
        sent = "Sent";
        drafts = "Drafts";
        trash = "Trash";
      };

      aerc.enable = true;
      # `default` (Inbox on open) is already implied by folders.inbox above;
      # folders-sort isn't derived from anything else, so it's set directly.
      aerc.extraAccounts."folders-sort" = "INBOX";

      # PGP signing/opportunistic-encryption, via aerc's `gpg` provider (see
      # general.pgp-provider in aerc/default.nix) and gpg-agent's pinentry
      # (both from den.aspects.gpg) — gated on config.programs.gpg.enable
      # rather than a host check, so this only activates on hosts that
      # actually include that aspect (currently alder only; aspen has no
      # GPG key yet). Fingerprint is the primary (Sign+Certify) key whose
      # uid matches meta.email — public fingerprints aren't secret, safe to
      # commit as-is.
      gpg = lib.mkIf config.programs.gpg.enable {
        key = "63CC52ABA2340A766FADA1465E1C908C6C7B78F6";
        signByDefault = true;
        # Only encrypts when every recipient's public key is already in the
        # keyring; never blocks sending to recipients without one.
        encryptByDefault = true;
      };
    };

    accounts.email.accounts.gmail = {
      address = "ivyturner78@gmail.com";
      realName = "ivy forever";
      flavor = "gmail.com";
      # Gmail app password, decrypted by sops-nix to /run/secrets (see
      # modules/sops.nix) — requires 2FA enabled on the Google account and
      # an app password generated at myaccount.google.com/apppasswords.
      passwordCommand = "cat /run/secrets/gmail-app-password";

      # Gmail's actual IMAP special-folder names, under Google's [Gmail]/
      # prefix — the module's plain "Inbox"/"Sent"/etc defaults don't match.
      folders = {
        inbox = "INBOX";
        sent = "[Gmail]/Sent Mail";
        drafts = "[Gmail]/Drafts";
        trash = "[Gmail]/Trash";
      };

      aerc.enable = true;
    };
  };
}
