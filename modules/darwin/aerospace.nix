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
          ctrl-alt-h = "focus left";
          ctrl-alt-j = "focus down";
          ctrl-alt-k = "focus up";
          ctrl-alt-l = "focus right";

          ctrl-alt-shift-h = "move left";
          ctrl-alt-shift-j = "move down";
          ctrl-alt-shift-k = "move up";
          ctrl-alt-shift-l = "move right";

          ctrl-alt-slash = "layout tiles horizontal vertical";
          ctrl-alt-comma = "layout accordion horizontal vertical";

          ctrl-alt-1 = "workspace 1";
          ctrl-alt-2 = "workspace 2";
          ctrl-alt-3 = "workspace 3";
          ctrl-alt-4 = "workspace 4";
          ctrl-alt-5 = "workspace 5";

          ctrl-alt-shift-1 = "move-node-to-workspace 1";
          ctrl-alt-shift-2 = "move-node-to-workspace 2";
          ctrl-alt-shift-3 = "move-node-to-workspace 3";
          ctrl-alt-shift-4 = "move-node-to-workspace 4";
          ctrl-alt-shift-5 = "move-node-to-workspace 5";

          ctrl-alt-shift-semicolon = "mode service";
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
