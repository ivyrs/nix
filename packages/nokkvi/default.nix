{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  makeWrapper,
  pipewire,
  alsa-lib,
  fontconfig,
  freetype,
  libglvnd,
  libxkbcommon,
  wayland,
  libX11,
  libXcursor,
  libXrandr,
  libXi,
  mesa,
  vulkan-loader,
  openssl,
  dbus,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nokkvi";
  version = "0.18.4";

  src = fetchFromGitHub {
    owner = "f-o-o-g-s";
    repo = "nokkvi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pjwqQ4ywUAoqtfdvyPBQu6IdHi88s7kDPMylrYGVdCk=";
  };

  # Upstream doesn't publish a flake yet, so this mirrors the buildRustPackage
  # derivation from their local (unpushed) flake.nix rather than consuming it
  # as a flake input.
  cargoHash = "sha256-RjcAjOWrPDqdHlqDEu/mzEmvb76iT5E/t0rRB0iEl8g=";
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pipewire
    alsa-lib
    fontconfig
    freetype
    libglvnd
    libxkbcommon
    wayland
    libX11
    libXcursor
    libXrandr
    libXi
    mesa
    vulkan-loader
    openssl
    dbus
  ];

  postInstall = ''
    wrapProgram $out/bin/nokkvi \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
      wayland
      libxkbcommon
      libglvnd
      mesa
      vulkan-loader
      libX11
      libXcursor
      libXrandr
      libXi
      pipewire
      alsa-lib
      fontconfig
      freetype
      openssl
      dbus
    ]}"

    install -Dm644 assets/org.nokkvi.nokkvi.desktop \
      $out/share/applications/org.nokkvi.nokkvi.desktop
    install -Dm644 assets/org.nokkvi.nokkvi.svg \
      $out/share/icons/hicolor/scalable/apps/org.nokkvi.nokkvi.svg
    install -Dm644 assets/org.nokkvi.nokkvi.png \
      $out/share/icons/hicolor/512x512/apps/org.nokkvi.nokkvi.png
  '';

  meta = {
    description = "A fast and beautiful Rust/Iced desktop client for Navidrome";
    homepage = "https://github.com/f-o-o-g-s/nokkvi";
    license = lib.licenses.gpl3Only;
    mainProgram = "nokkvi";
    platforms = lib.platforms.linux;
  };
})
