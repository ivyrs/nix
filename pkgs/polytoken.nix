{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:
let
  releases = {
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "sha256-U29jGD+IoDmjx/dslUg9RK5ppv7Xgdc2XCNVkiP8ywc=";
    };
    x86_64-linux = {
      platform = "linux-amd64";
      hash = "sha256-XUvZjBGQoMpaYt25fQHoXZMAdol93jLxxXxRuyD2zIg=";
    };
    aarch64-darwin = {
      platform = "macos-arm64";
      hash = "sha256-hDikM57Cy2+dIMbTo1Ax27uk2oV+g3g0hOU8d2SCSic=";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "polytoken";
  version = "0.9.5";

  # Official stable-channel binaries; hashes from SHA256SUMS.linux/macos.
  src = fetchurl {
    url = "https://dl.polytoken.dev/${finalAttrs.version}/${release.platform}/polytoken";
    inherit (release) hash;
  };

  dontUnpack = true;
  dontStrip = true;
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/polytoken"
    runHook postInstall
  '';

  meta = {
    description = "Terminal-based AI coding agent";
    homepage = "https://polytoken.dev";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    license = lib.licenses.unfree;
    mainProgram = "polytoken";
    platforms = builtins.attrNames releases;
  };
})
