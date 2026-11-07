{ config, pkgs, ... }:
let
  lock = "${pkgs.systemd}/bin/systemctl --user start desktop-lock.service";
  locker = pkgs.writeShellScript "desktop-lock-service" ''
    # Keep swaylock and its PAM helper out of the launcher's terminal/session.
    # Notify systemd only after swaylock confirms the compositor has locked.
    exec ${pkgs.swaylock}/bin/swaylock --ready-fd 3 3> >(
      IFS= read -r _ && ${pkgs.systemd}/bin/systemd-notify --ready
    )
  '';
  niri = "${pkgs.niri}/bin/niri";
in
{
  programs.swaylock = {
    enable = true;
    settings = {
      # A local image, not a dependency on Noctalia's runtime state. If absent,
      # swaylock keeps the solid background rather than refusing to lock.
      image = "${config.home.homeDirectory}/media/images/wp-new/dark/wallhaven-qrp9ql.png";
      scaling = "fill";
      color = "282828";
      font = "sans-serif";
      font-size = 20;
      hide-keyboard-layout = true;
      indicator-radius = 64;
      indicator-thickness = 3;
      ring-color = "d5c4a180";
      ring-ver-color = "83a598";
      ring-wrong-color = "fb4934";
      ring-clear-color = "fabd2f";
      ring-caps-lock-color = "fabd2f";
      key-hl-color = "b8bb26";
      bs-hl-color = "fabd2f";
      separator-color = "00000000";
      inside-color = "282828b3";
      inside-ver-color = "282828b3";
      inside-wrong-color = "282828b3";
      inside-clear-color = "282828b3";
      inside-caps-lock-color = "282828b3";
      text-color = "ebdbb2";
      text-ver-color = "ebdbb2";
      text-wrong-color = "fb4934";
      text-clear-color = "fabd2f";
      text-caps-lock-color = "fabd2f";
      line-uses-inside = true;
      show-failed-attempts = true;
      ignore-empty-password = true;
      indicator-idle-visible = true;
    };
  };

  systemd.user.services.desktop-lock = {
    Unit = {
      Description = "Screen locker independent of launcher lifetime";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
    };
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${locker}";
      Restart = "on-failure";
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "desktop-lock" ''
      # Starting an already running locker is harmless; wait for lock readiness.
      exec ${lock}
    '')
  ];

  services.swayidle = {
    enable = true;
    systemdTargets = [ "niri.service" ];
    # systemctl waits for the lock service's readiness notification.
    extraArgs = [ "-w" ];
    events = {
      before-sleep = lock;
      lock = lock;
      after-resume = "${niri} msg action power-on-monitors";
    };
    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 400;
        command = "${niri} msg action power-off-monitors";
        resumeCommand = "${niri} msg action power-on-monitors";
      }
    ];
  };
}
