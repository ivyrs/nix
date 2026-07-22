# Stats for elm itself plus the other machines running the glance agent.
{
  meta,
  tokenFile,
}: {
  type = "server-stats";
  servers = [
    {
      type = "local";
      name = "elm";
    }
    {
      type = "remote";
      url = "http://fountain.${meta.tailnet}:27973";
      name = "fountain";
      token = {_secret = tokenFile;};
    }
  ];
}
