{
  flake.modules.darwin.homebrew = {
    nix-homebrew = {
      enable = true;
      enableRosetta = true;   # also set up the Intel prefix for x86-only casks
      user = "ivy";
    };

    homebrew = {
      enable = true;

      onActivation = {
        autoUpdate = true;   # set false for faster, more deterministic switches
        upgrade = true;
        cleanup = "zap";     # removes + zaps anything not listed below.
      };

      brews = [
        "mas"   # uncomment if you use the masApps block below
      ];

      casks = [
        "obsidian"       # notes
        "bitwarden"      # Vaultwarden client
        "tailscale-app"  # menu-bar GUI (formula `tailscale` is CLI-only)
        "keymapp"        # ZSA Moonlander flasher
        "gram"
        "helium-browser"
        "raycast"
        "shottr"
        "claude"
      ];

      masApps = {
        #"Things" = 904237743;   # verify before uncommenting
      };
    };
  };
}
