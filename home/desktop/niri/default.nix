{ pkgs, ... }:

{
  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    "niri/binds.kdl".source = ./binds.kdl;
    "niri/settings.kdl".source = ./settings.kdl;
    "niri/ux.kdl".source = ./ux.kdl;
  };

  services.udiskie.enable = true;

  home.packages = [
    pkgs.playerctl # media keys, including standalone homeModules.niri consumers
    pkgs.wl-clipboard # move this into a Desktop file when it makes sense

    (pkgs.writeShellApplication {
      name = "focus-or-spawn";

      runtimeInputs = [
        pkgs.jq
        pkgs.niri
      ];

      text = ''
        app_id=$1
        shift

        id=$(
          niri msg -j windows |
            jq -r --arg app "$app_id" \
              '[.[] | select(.app_id == $app)][0].id // empty'
        )

        if [ -n "$id" ]; then
          exec niri msg action focus-window --id "$id"
        else
          exec "$@"
        fi
      '';
    })

    (pkgs.writeShellApplication {
      name = "niri-pip-follow";

      runtimeInputs = [
        pkgs.jq
        pkgs.niri
      ];

      # Keeps the Firefox picture-in-picture window on whatever workspace
      # is currently focused, moving it along whenever you switch.
      text = ''
        while true; do
          niri msg -j event-stream | jq -c --unbuffered '
            select(.WorkspaceActivated != null and .WorkspaceActivated.focused == true)
            | .WorkspaceActivated.id
          ' | while read -r ws_id; do
            idx=$(niri msg -j workspaces | jq -r --argjson id "$ws_id" '.[] | select(.id == $id) | .idx')
            [ -z "$idx" ] && continue

            win_json=$(niri msg -j windows | jq -c '
              [.[] | select(.app_id == "firefox" and .title == "Picture-in-Picture")][0] // empty
            ')
            [ -z "$win_json" ] && continue

            win_id=$(jq -r '.id' <<< "$win_json")
            win_ws=$(jq -r '.workspace_id' <<< "$win_json")
            [ "$win_ws" = "$ws_id" ] && continue

            niri msg action move-window-to-workspace --window-id "$win_id" --focus false "$idx" || true
          done || true
          sleep 1
        done
      '';
    })
  ];
}
