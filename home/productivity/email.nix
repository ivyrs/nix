{
  config,
  lib,
  metadata,
  ...
}:

{
  accounts.email.accounts = {
    ivy = {
      primary = true;
      address = metadata.user.emails.primary;
      realName = metadata.user.fullName;

      flavor = "fastmail.com";

      smtp.tls.useStartTls = true;

      passwordCommand = "cat /run/secrets/aerc-fastmail-password";

      folders = {
        inbox = "INBOX";
        sent = "Sent";
        drafts = "Drafts";
        trash = "Trash";
      };

      aerc = {
        enable = true;
        extraAccounts."folders-sort" = "INBOX";
      };

      gpg = lib.mkIf config.programs.gpg.enable {
        key = "63CC52ABA2340A766FADA1465E1C908C6C7B78F6";
        signByDefault = true;
        encryptByDefault = true;
      };
    };

    gmail = {
      address = metadata.user.emails.gmail;
      realName = metadata.user.fullName;

      flavor = "gmail.com";

      passwordCommand = "cat /run/secrets/gmail-app-password";

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
