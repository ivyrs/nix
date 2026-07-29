{
  den.aspects.aerospace.darwin = {
    services.aerospace = {
      enable = true;

      settings = {
        gaps = {
          outer.left = 8;
          outer.bottom = 8;
          outer.top = 8;
          outer.right = 8;
          inner.horizontal = 8;
          inner.vertical = 8;
        };

        default-root-container-orientation = "horizontal";

        mode.main.binding = {
          ctrl-h = "focus left";
          ctrl-j = "focus down";
          ctrl-k = "focus up";
          ctrl-l = "focus right";

          ctrl-shift-h = "move left";
          ctrl-shift-j = "move down";
          ctrl-shift-k = "move up";
          ctrl-shift-l = "move right";

          ctrl-slash = "layout tiles horizontal vertical";
          ctrl-comma = "layout accordion horizontal vertical";

          ctrl-1 = "workspace wrk";
          ctrl-2 = "workspace web";
          ctrl-3 = "workspace pro";
          ctrl-4 = "workspace cht";
          ctrl-5 = "workspace mus";
          ctrl-6 = "workspace 6";
          ctrl-7 = "workspace 7";
          ctrl-8 = "workspace 8";
          ctrl-9 = "workspace 9";
          ctrl-0 = "workspace 10";

          ctrl-shift-1 = "move-node-to-workspace wrk";
          ctrl-shift-2 = "move-node-to-workspace web";
          ctrl-shift-3 = "move-node-to-workspace pro";
          ctrl-shift-4 = "move-node-to-workspace cht";
          ctrl-shift-5 = "move-node-to-workspace mus";
          ctrl-shift-6 = "move-node-to-workspace 6";
          ctrl-shift-7 = "move-node-to-workspace 7";
          ctrl-shift-8 = "move-node-to-workspace 8";
          ctrl-shift-9 = "move-node-to-workspace 9";
          ctrl-shift-0 = "move-node-to-workspace 10";

          ctrl-shift-semicolon = "mode service";
        };

        mode.service.binding = {
          esc = ["reload-config" "mode main"];
          r = ["flatten-workspace-tree" "mode main"];
          f = ["layout floating tiling" "mode main"];
        };

        on-window-detected = [
          {
            "if".app-id = "net.imput.helium";
            run = "move-node-to-workspace web";
          }
          {
            "if".app-id = "md.obsidian";
            run = "move-node-to-workspace pro";
          }
          {
            "if".app-id = "com.apple.iCal";
            run = "move-node-to-workspace pro";
          }
          {
            "if".app-id = "dev.vencord.vesktop";
            run = "move-node-to-workspace cht";
          }
          {
            "if".app-id = "com.apple.MobileSMS";
            run = "move-node-to-workspace cht";
          }
          {
            "if".app-id = "com.apple.Music";
            run = "move-node-to-workspace mus";
          }
          {
            "if".app-id = "org.jeffvli.feishin";
            run = "move-node-to-workspace mus";
          }
        ];
      };
    };
  };
}
