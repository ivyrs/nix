# Uptime monitor for the self-hosted services.
{ meta }:
{
  type = "monitor";
  cache = "1m";
  title = "Services";
  sites = [
    {
      title = "syncthing";
      url = "http://elm.${meta.tailnet}:8384";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/syncthing.png";
    }
    {
      title = "RSS";
      url = "https://rss.${meta.domain}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/miniflux.png";
    }
    # {
    #   title = "hTodo";
    #   url = "https://todo.${meta.domain}";
    #   icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vikunja.png";
    # }
    {
      title = "vaultwarden";
      url = "https://vault.${meta.domain}";
      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/vaultwarden.png";
    }
    {
      title = "houseplantsID";
      url = meta.oidcIssuer;
      icon = "/assets/ivyid-logo.png";
    }
  ];
}
