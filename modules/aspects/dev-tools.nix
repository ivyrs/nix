{
  # Development tools and language runtimes.
  # Opted in by hosts/users who need a local dev environment (e.g. aspen/macOS).
  den.aspects.dev-tools.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      devenv
      nodejs
      rustup
      go
    ];
  };
}
