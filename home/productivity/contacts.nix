{ metadata, ... }:

{
  accounts.contact = {
    basePath = ".local/share/contacts";

    accounts.nextcloud = {
      remote = {
        type = "carddav";
        url = "https://cloud.${metadata.domains.services}/remote.php/dav/";
        userName = metadata.user.username;
        passwordCommand = [
          "cat"
          "/run/secrets/ivy-nextcloud-app-password"
        ];
      };

      vdirsyncer = {
        enable = true;

        collections = [
          "contacts"
        ];

        conflictResolution = "remote wins";
      };

      khard = {
        enable = true;
        addressbooks = [
          "contacts"
        ];
      };
    };
  };

  programs = {
    vdirsyncer.enable = true;
    khard.enable = true;
  };
}
