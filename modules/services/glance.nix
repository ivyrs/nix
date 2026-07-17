{
  flake.modules.nixos.glance = { config, ... }: {
    services.glance = {
      enable = true;
      settings = {
        server = {
          host = "0.0.0.0";
          port = 8080;
          assets-path = ./glance-assets;
        };
        theme = {
          background-color = "240 21.1 14.9";
          primary-color = "232 97.4 85.1";
          contrast-multiplier = 1.1;
          custom-css-file = "/assets/user.css";
        };
        pages = [
          {
            name = "Home";
            hide-desktop-navigation = true;
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "split-column";
                    widgets = [
                      {
                        type = "group";
                        widgets = [
                          {
                            type = "clock";
                            hour-format = "24h";
                            timezones = [
                              {
                                timezone = "America/Anchorage";
                                label = "Alaska";
                              }
                              {
                                timezone = "America/Chicago";
                                label = "EST";
                              }
                              {
                                timezone = "America/New_York";
                                label = "new york";
                              }
                              {
                                timezone = "Europe/Berlin";
                                label = "Berlin";
                              }
                            ];
                          }
                          {
                            type = "calendar";
                            first-day-of-week = "monday";
                          }
                        ];
                      }
                      {
                        type = "weather";
                        location = { _secret = config.sops.secrets.glance-city.path; };
                        units = "metric";
                        hour-format = "24h";
                        hide-location = true;
                      }
                    ];
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
                      {
                        title = "Syncthing";
                        url = "http://elm.ocelot-perch.ts.net:8384";
                        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/syncthing.png";
                      }
                      {
                        title = "Miniflux";
                        url = "http://elm.ocelot-perch.ts.net:3000";
                        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/miniflux.png";
                      }
                      {
                        title = "htodo";
                        url = "https://todo.houseplants.cloud";
                        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vikunja.png";
                      }
                      {
                        title = "vaultwarden";
                        url = "https://vault.houseplants.cloud";
                        icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vaultwarden.png";
                      }
                      {
                        title = "ivyid";
                        url = "https://id.ivy.rs";
                        icon = "/assets/ivyid-logo.png";
                      }
                    ];
                  }
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = "elm";
                      }
                      {
                        type = "remote";
                        url = "http://houseplants.ocelot-perch.ts.net:27973";
                        name = "houseplants";
                        token = { _secret = config.sops.secrets.glance-agent-token.path; };
                      }
                      {
                        type = "remote";
                        url = "http://lovecomputer.ocelot-perch.ts.net:27973";
                        name = "lovecomputer";
                        token = { _secret = config.sops.secrets.glance-agent-token.path; };
                      }
                      {
                        type = "remote";
                        url = "http://fountain.ocelot-perch.ts.net:27973";
                        name = "fountain";
                        token = { _secret = config.sops.secrets.glance-agent-token.path; };
                      }
                    ];
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        links = [
                          {
                            title = "fastmail";
                            url = "https://app.fastmail.com";
                          }
                          {
                            title = "codeberg";
                            url = "https://codeberg.org";
                          }
                          {
                            title = "github";
                            url = "https://github.com";
                          }
                          {
                            title = "phanpy";
                            url = "https://phanpy.social";
                          }
                        ];
                      }
                      {
                        color = "316.4 71.8 85.9";
                        links = [
                          {
                            title = "youtube";
                            url = "https://youtube.com";
                          }
                          {
                            title = "geforce now";
                            url = "https://play.geforcenow.com/mall/#/layout/games";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8080 ];
  };
}
