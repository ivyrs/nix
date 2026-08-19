{
  den.aspects.librewolf.homeManager = {pkgs, ...}: let
    # home-manager's programs.librewolf.profiles.<name>.extensions.packages
    # expects each package's .xpi under share/mozilla/extensions/{ec8030f7-…}/
    # (see mkFirefoxModule.nix's `extensionPath`) — that's the layout NUR's
    # rycee.firefox-addons wraps for you. We don't depend on NUR, so wrap
    # pkgs.fetchFirefoxAddon's flat $out/<extid>.xpi output into that shape
    # ourselves.
    mkAddon = {
      name,
      url,
      sha256,
    }: let
      xpi = pkgs.fetchFirefoxAddon {inherit name url sha256;};
    in
      pkgs.runCommand "librewolf-addon-${name}" {passthru.addonId = xpi.extid;} ''
        dir="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dir"
        ln -s "${xpi}/${xpi.extid}.xpi" "$dir/${xpi.extid}.xpi"
      '';
  in {
    programs.librewolf = {
      enable = true;

      profiles.ivy = {
        isDefault = true;

        # Mozilla's newer multi-profile picker (rolled out ~Oct 2025) layers
        # its own SQLite "Profile Groups" DB on top of profiles.ini and
        # labels whatever profile already existed "Original Profile",
        # ignoring the Name set here. We only ever run one profile, so just
        # turn the picker off rather than fight its separate naming state.
        settings."browser.profiles.enabled" = false;

        # Auto-enable extensions installed via extensions.packages instead of
        # leaving them disabled pending manual approval in about:addons.
        settings."extensions.autoDisableScopes" = 0;

        extensions.packages = [
          (mkAddon {
            name = "bitwarden-password-manager";
            url = "https://addons.mozilla.org/firefox/downloads/file/4915668/bitwarden_password_manager-2026.7.0.xpi";
            sha256 = "sha256-EYNuudKryZFLsze1fiDFoJz0TyT6Vy9+iGOE/TUKURI=";
          })
          (mkAddon {
            name = "styl-us";
            url = "https://addons.mozilla.org/firefox/downloads/file/4947910/styl_us-2.4.10.xpi";
            sha256 = "sha256-kHwevP6qp4iQ74LrsaAE+OYH/kgglRZc0bgwk3MRISk=";
          })
          (mkAddon {
            name = "pywalfox";
            url = "https://addons.mozilla.org/firefox/downloads/file/4834767/pywalfox-2.1.1.xpi";
            sha256 = "sha256-t6eobR1JqDCXWM4dOEkpdavgemHjeI4tkTxwpNB3WLQ=";
          })
          (mkAddon {
            name = "vimium-ff";
            url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi";
            sha256 = "sha256-Ex4qZ1gOeukSWrGXgRWeYUCfrEe0Qfwngqq3Y5bq0ZY=";
          })
        ];
      };
    };
  };
}
