{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  gitMinimal,
  wayland-scanner,
  wayland,
  sqlite,
  xxhash,
  coreutils,
  runCommand,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cclip";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "heather7283";
    repo = "cclip";
    rev = "55521a83278f4a1c1bf96b6b25bf543c8350d4c3";
    hash = "sha256-tUS6EGXSbd46lcDO2/GXxJv9ym3QaCt0k7ufnyvXH1Q=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gitMinimal
    wayland-scanner
  ];
  buildInputs = [
    wayland
    sqlite
    xxhash
  ];

  # Upstream creates the clipboard database through install on PATH, mode 644.
  # Clipboard history should only be readable by its owner.
  postPatch = ''
    substituteInPlace src/common/db.c \
      --replace-fail 'execlp("install", "install", "-Dm644"' \
        'execl("${coreutils}/bin/install", "install", "-Dm600"'
  '';

  passthru.tests.database = import ../tests/cclip.nix {
    inherit runCommand sqlite;
    cclip = finalAttrs.finalPackage;
  };

  meta = {
    description = "Wayland clipboard history daemon and CLI for fsel";
    homepage = "https://github.com/heather7283/cclip";
    license = lib.licenses.gpl3Plus;
    mainProgram = "cclip";
    platforms = lib.platforms.linux;
  };
})
