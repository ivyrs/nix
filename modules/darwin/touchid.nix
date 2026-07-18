{
  flake.modules.darwin.touchid = {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
