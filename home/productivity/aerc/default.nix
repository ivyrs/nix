{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.chafa
  ];

  programs.aerc = {
    enable = true;

    extraConfig = {
      general = {
        unsafe-accounts-conf = true;
        mouse-enabled = true;
      }
      // lib.optionalAttrs config.programs.gpg.enable {
        pgp-provider = "gpg";
        use-terminal-pinentry = true;
      };

      ui.styleset-name = lib.mkDefault "catppuccin-mocha";

      compose."address-book-cmd" = "khard email --parsable --remove-first-line %s";

      filters = {
        "text/plain" = "colorize";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/html" = "! html";
        ".headers" = "colorize";
        "image/*" = "chafa -f symbols";
      };

      openers =
        if pkgs.stdenv.hostPlatform.isDarwin then
          {
            "text/html" = "open -a Safari";
            "image/*" = "open -a Preview";
            "application/pdf" = "open -a Preview";
          }
        else
          {
            "text/html" = "xdg-open";
            "image/*" = "xdg-open";
            "application/pdf" = "xdg-open";
          };
    };

    stylesets = {
      catppuccin-mocha = builtins.readFile ./mocha-styleset.conf;

      # Lets Noctalia replace this later if you still wire that up.
      noctalia = lib.mkDefault "";
    };
  };
}
