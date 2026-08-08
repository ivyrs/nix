# CardDAV contacts via vdirsyncer (sync) + khard (CLI address book), same
# workstation-only scope and pairing pattern as calendars.nix. Nextcloud is
# the primary account; iCloud adds its own address book. Both accounts
# reuse the same secrets already declared for the calendar accounts (app
# passwords are account-wide, not calendar-specific).
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.desktop.homeManager = {...}: {
    accounts.contact = {
      basePath = ".contacts";

      accounts = {
        nextcloud = {
          remote = {
            type = "carddav";
            url = "https://cloud.${meta.domain}/remote.php/dav/";
            userName = "ivy";
            passwordCommand = ["cat" "/run/secrets/ivy-nextcloud-app-password"];
          };

          vdirsyncer = {
            enable = true;
            # Nextcloud's default (and, here, only) address book slug.
            # If more address books get added later, list them here the
            # same way calendars.nix pins each calendar explicitly.
            collections = ["contacts"];
            conflictResolution = "remote wins";
          };

          khard = {
            enable = true;
            addressbooks = ["contacts"];
          };
        };

        icloud = {
          remote = {
            type = "carddav";
            url = "https://contacts.icloud.com/";
            passwordCommand = ["cat" "/run/secrets/icloud-password"];
          };

          vdirsyncer = {
            enable = true;
            userNameCommand = ["cat" "/run/secrets/icloud-username"];
            # iCloud only exposes one default address book per account and
            # (unlike its calendars) doesn't split it into opaque-UUID
            # collections, so autodiscovery is safe here.
            collections = ["from a"];
            conflictResolution = "remote wins";
          };

          khard = {
            enable = true;
            type = "discover";
          };
        };
      };
    };

    programs.vdirsyncer.enable = true;
    programs.khard.enable = true;
  };
}
