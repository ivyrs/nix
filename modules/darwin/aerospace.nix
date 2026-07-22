{
  flake.modules.darwin.aerospace = {
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

        default-root-container-orientation = "vertical";

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

          ctrl-1 = "workspace 1";
          ctrl-2 = "workspace 2";
          ctrl-3 = "workspace 3";
          ctrl-4 = "workspace 4";
          ctrl-5 = "workspace 5";

          ctrl-shift-1 = "move-node-to-workspace 1";
          ctrl-shift-2 = "move-node-to-workspace 2";
          ctrl-shift-3 = "move-node-to-workspace 3";
          ctrl-shift-4 = "move-node-to-workspace 4";
          ctrl-shift-5 = "move-node-to-workspace 5";

          ctrl-shift-semicolon = "mode service";
        };

        mode.service.binding = {
          esc = [ "reload-config" "mode main" ];
          r = [ "flatten-workspace-tree" "mode main" ];
          f = [ "layout floating tiling" "mode main" ];
        };
      };
    };
  };
}
