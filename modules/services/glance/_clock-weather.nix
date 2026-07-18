# Clock + calendar next to the weather, in one split column.
{ cityFile }:
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
      location = { _secret = cityFile; };
      units = "metric";
      hour-format = "24h";
      hide-location = true;
    }
  ];
}
