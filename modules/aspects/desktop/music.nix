# Music/audio client tooling, gathered in one place rather than scattered
# across desktop/default.nix and host files. multi-scrobbler
# (services/multi-scrobbler.nix) stays separate — an elm-only Docker backend
# service, not a client-side app a workstation user opts into.
{
  # ncspot: terminal Spotify client, cross-platform (aspen + alder home.nix).
  den.aspects.music.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.ncspot];
  };

  # feishin + nokkvi: Subsonic/Navidrome GUI clients for the navidrome
  # instance glance monitors (see glance/_monitor-sites.nix) — Linux-only,
  # so nixos-class (alder).
  den.aspects.music.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.feishin
      (pkgs.callPackage ../../../packages/nokkvi/default.nix {})
    ];
  };
}
