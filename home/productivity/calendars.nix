{ metadata, ... }:

{
  programs = {
    vdirsyncer.enable = true;
    khal = {
      enable = true;
      settings.default.default_calendar = "personal";
    };

    todoman = {
      enable = true;
      glob = "*/*";
    };
  };

  accounts.calendar = {
    basePath = ".local/share/calendars";

    accounts = {
      nextcloud = {
        primary = true;
        remote = {
          type = "caldav";
          url = "https://cloud.${metadata.domains.services}/remote.php/dav/calendars/${metadata.user.username}/";
          userName = metadata.user.username;
          passwordCommand = [
            "cat"
            "/run/secrets/ivy-nextcloud-app-password"
          ];
        };

        local = {
          type = "filesystem";
          fileExt = ".ics";
        };

        vdirsyncer = {
          enable = true;

          collections = [
            "personal"
            "love-computer"
            "contact_birthdays"
            "routines"
            [
              "focus"
              "02B695BE-0A2A-49F7-9123-57102E1B9213"
              "focus"
            ]
            [
              "band"
              "316EC6A0-39CC-4207-BF20-F5AAFF41919E"
              "band"
            ]
            [
              "money"
              "96E8D86B-8B89-4819-93A8-A766D22E99C1"
              "money"
            ]
            [
              "routines-breaks"
              "018ED70D-2567-4A5F-919B-76FCD0328BD1"
              "routines-breaks"
            ]
            "inbox-1"
            "wait"
            "projects"
            "someday"
            "next"
          ];

          conflictResolution = "remote wins";
        };

        khal.enable = true;
        khal.type = "discover";
      };

      # TODO: fix your apple id
    };
  };
}
