# CalDAV calendars via vdirsyncer (sync) + khal (CLI/TUI view), same
# workstation-only scope as the rest of desktop/default.nix. Nextcloud is
# the primary account; iCloud adds a handful of shared/personal calendars.
# Both accounts pin an explicit `collections` list (see comments below)
# rather than autodiscovering everything with "from a".
{config, ...}: let
  meta = config.flake.lib.meta;
in {
  den.aspects.desktop.homeManager = {...}: {
    accounts.calendar = {
      basePath = ".calendar";

      accounts = {
        nextcloud = {
          primary = true;
          # khal needs a concrete default calendar since "from a" discovers
          # several; the account name itself ("nextcloud") isn't a real
          # collection so khal would otherwise refuse to start.
          primaryCollection = "personal";
          remote = {
            type = "caldav";
            url = "https://cloud.${meta.domain}/remote.php/dav/";
            userName = "ivy";
            # Nextcloud app password, decrypted by sops-nix to /run/secrets
            # (see modules/sops.nix) — same secret declared for
            # ivy-nextcloud-app-password already, app passwords are
            # account-wide so it's fine to reuse here.
            passwordCommand = ["cat" "/run/secrets/ivy-nextcloud-app-password"];
          };

          vdirsyncer = {
            enable = true;

            collections = [
              "personal"
              "love-computer"
              "contact_birthdays"
              "routines"
              "tasks"
              ["focus" "02B695BE-0A2A-49F7-9123-57102E1B9213" "focus"]
              ["band" "316EC6A0-39CC-4207-BF20-F5AAFF41919E" "band"]
              ["money" "96E8D86B-8B89-4819-93A8-A766D22E99C1" "money"]
              ["routines-breaks" "018ED70D-2567-4A5F-919B-76FCD0328BD1" "routines-breaks"]
            ];
            conflictResolution = "remote wins";
          };

          khal = {
            enable = true;
            type = "discover";
          };
        };

        icloud = {
          remote = {
            type = "caldav";
            url = "https://caldav.icloud.com/";
            # Apple ID kept out of the nix store entirely, not just the
            # password — this repo's Codeberg remote is public.
            passwordCommand = ["cat" "/run/secrets/icloud-password"];
          };

          vdirsyncer = {
            enable = true;
            userNameCommand = ["cat" "/run/secrets/icloud-username"];

            collections = [
              ["ic-home" "120638F4-CF02-48D9-A1A8-23E3187F39D8" "ic-home"]
              ["ic-events" "3CF03A8D-1C6F-4F83-878D-5F044764F97C" "ic-events"]
              ["ic-family" "6672a84a5a3e09d553a90a70cbf9866deedc87984538d26ecb0fb665f34b81e0" "ic-family"]
              ["ic-inflow" "FA08E043-99D3-4F08-9FF1-AC5FAE38121B" "ic-inflow"]
            ];
            conflictResolution = "remote wins";
          };

          khal = {
            enable = true;
            type = "discover";
          };
        };
      };
    };

    programs.vdirsyncer.enable = true;
    programs.khal.enable = true;

    xdg.configFile."todoman/config.py".text = ''
      path = "~/.calendar/nextcloud/*"
      date_format = "%Y-%m-%d"
      time_format = "%H:%M"
      default_list = "tasks"
      default_due = 0
     '';
  };
}
