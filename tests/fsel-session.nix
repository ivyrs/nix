{ pkgs }:
let
  module = import ../home/desktop/fsel { inherit pkgs; };
  service = module.systemd.user.services.cclip;
in
# Home Manager's switch logic only starts new units wanted by active targets.
# Depending on niri.service here leaves cclip dormant until the next login.
assert builtins.elem "graphical-session.target" service.Install.WantedBy;
assert builtins.elem "graphical-session.target" service.Unit.PartOf;
assert builtins.elem "graphical-session.target" service.Unit.After;
assert service.Unit.ConditionEnvironment == "WAYLAND_DISPLAY";
assert service.Service.UMask == "0077";
pkgs.runCommand "fsel-session-test" { } ''
  touch "$out"
''
