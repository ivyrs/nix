# Email account definitions (home-manager's `accounts.email` module),
# consumed by aerc via each account's `aerc.enable = true` — kept separate
# from productivity/aerc/default.nix so the account data (address,
# credentials) isn't tangled with the aerc client's own UI/filter config.
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.desktop.homeManager = {...}: {
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
