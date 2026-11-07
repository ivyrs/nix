{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "nmrs-tui";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "y2w8";
    repo = "nmrs-tui";
    rev = "e9b9c993536cc8b1a5638870e1f724d12363bf48";
    hash = "sha256-V+9BCpxrX7auo2NCj5JCIu8F8d74TTt7pHh+oVhpHBs=";
  };

  cargoHash = "sha256-WTPzc+IFGaf9LmKzhyGveOTcO3nWlm/If5zbGpqlNp0=";

  meta = {
    description = "Keyboard-first NetworkManager TUI";
    homepage = "https://github.com/y2w8/nmrs-tui";
    license = lib.licenses.gpl3Only;
    mainProgram = "nmrs-tui";
    platforms = lib.platforms.linux;
  };
}
