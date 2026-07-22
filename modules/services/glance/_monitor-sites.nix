# Uptime monitor for the self-hosted services.
{meta}: {
  type = "monitor";
  cache = "1m";
  title = "Services";
  sites = [
    {
      title = "nextcloud";
      url = "https://cloud.${meta.domain}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/nextcloud.png";
    }
    {
      title = "syncthing";
      url = "http://elm.${meta.tailnet}:8384";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/syncthing.png";
    }
    {
      title = "vaultwarden";
      url = "https://vault.${meta.domain}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vaultwarden.png";
    }
    {
      title = "RSS";
      url = "https://rss.${meta.domain}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/miniflux.png";
    }
    {
      title = "houseplantsID";
      url = meta.oidcIssuer;
      icon = "/assets/houseplants-logo.png";
    }
    {
      title = "forgejo";
      url = "https://git.${meta.domain}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/forgejo.png";
    }
    {
      title = "navidrome";
      url = "https://music.moose-amberjack.ts.net";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/syncthing.png";
    }
  ];
}
