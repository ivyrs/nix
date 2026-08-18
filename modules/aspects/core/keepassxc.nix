# Terminal-adjacent, fully open-source alternative to den.aspects.pass
# (formerly modules/aspects/core/pass.nix): KeePassXC for secret storage,
# with its own SSH Agent feature taking over the SSH-auth/git-signing role
# gpg-agent used to play. Cut over on alder (see hosts/alder/home.nix's
# IdentityAgent/git signing overrides); the actual database file,
# generating a fresh SSH keypair for the agent, and enabling KeePassXC's SSH
# Agent in-app are all manual, do-by-hand steps; nothing here does that for
# you. KeePassXC's nixpkgs build already ships its own browser
# native-messaging manifest, so no separate browser-integration module is
# needed the way den.aspects.pass needed programs.browserpass.
{
  den.aspects.keepassxc.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.keepassxc];
  };
}
