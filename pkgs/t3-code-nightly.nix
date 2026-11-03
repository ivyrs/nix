{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  unzip,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libsecret,
  libxkbcommon,
  libxshmfence,
  nspr,
  nss,
  pango,
  systemdLibs,
  vulkan-loader,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libxcb,
  libxkbfile,
  libnotify,
  libpulseaudio,
  pciutils,
  cloudflared,
  git,
  gh,
}:
let
  # Update this version and all three hashes together from upstream nightly assets.
  version = "0.1.7-nightly.20261102.4080";
  pname = "t3-code-nightly";
  releases = {
    aarch64-linux = {
      suffix = "arm64.AppImage";
      hash = "sha256-0ERCCe56qv2wJeGU9xyXjrZ0H0HqTmJisFFz/0yuFeY=";
    };
    x86_64-linux = {
      suffix = "x86_64.AppImage";
      hash = "sha256-sGYHVqR8wHZQuGfmlDPwJcJho3KuMRRsawuoJZasxzg=";
    };
    aarch64-darwin = {
      suffix = "arm64.zip";
      hash = "sha256-PXqwfV+RKARotU+dWcqxDTcJ0veVWLYuWLSdn/RpWbE=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-${release.suffix}";
    inherit (release) hash;
  };
  meta = {
    description = "T3 Code nightly desktop and CLI, with upstream T3 Connect configuration";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames releases;
    mainProgram = "t3code";
  };
in
if stdenv.hostPlatform.isDarwin then
  stdenvNoCC.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;
    nativeBuildInputs = [
      makeWrapper
      unzip
    ];
    # Do not mutate the upstream signed bundle.
    dontFixup = true;
    unpackPhase = ''
      runHook preUnpack
      unzip -q "$src"
      runHook postUnpack
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications" "$out/bin"
      cp -R "T3 Code (Nightly).app" "$out/Applications/"
      app="$out/Applications/T3 Code (Nightly).app/Contents"
      makeWrapper "$app/MacOS/T3 Code (Nightly)" "$out/bin/t3code" \
        --set T3CODE_DISABLE_AUTO_UPDATE 1 \
        --prefix PATH : ${
          lib.makeBinPath [
            cloudflared
            git
            gh
          ]
        }
      makeWrapper "$app/MacOS/T3 Code (Nightly)" "$out/bin/t3" \
        --set ELECTRON_RUN_AS_NODE 1 \
        --set T3CODE_DISABLE_AUTO_UPDATE 1 \
        --add-flag "$app/Resources/app.asar/apps/server/dist/bin.mjs" \
        --prefix PATH : ${
          lib.makeBinPath [
            cloudflared
            git
            gh
          ]
        }
      runHook postInstall
    '';
  }
else
  stdenv.mkDerivation (finalAttrs: {
    inherit pname version meta;
    src = appimageTools.extract { inherit pname version src; };
    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      wrapGAppsHook3
    ];
    buildInputs = [
      alsa-lib
      at-spi2-atk
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libGL
      libdrm
      libgbm
      libsecret
      libxkbcommon
      libxshmfence
      nspr
      nss
      pango
      stdenv.cc.cc
      systemdLibs
      vulkan-loader
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libxcb
      libxkbfile
    ];
    appendRunpaths = map (pkg: "${lib.getLib pkg}/lib") [
      libGL
      libnotify
      libpulseaudio
      libsecret
      pciutils
      vulkan-loader
    ];
    # Optional musl prebuilds are not loaded by the glibc Electron runtime.
    autoPatchelfIgnoreMissingDeps = [
      "libc.musl-x86_64.so.1"
      "libc.musl-aarch64.so.1"
    ];
    dontWrapGApps = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/libexec/t3-code-nightly" "$out/bin" "$out/share/applications" "$out/share/icons"
      cp -R . "$out/libexec/t3-code-nightly"
      chmod -R u+w "$out/libexec/t3-code-nightly"
      install -Dm444 t3code.desktop "$out/share/applications/t3-code-nightly.desktop"
      cp -R usr/share/icons/hicolor "$out/share/icons/"
      substituteInPlace "$out/share/applications/t3-code-nightly.desktop" \
        --replace-fail "Exec=AppRun" "Exec=t3code"
      rm -rf "$out/libexec/t3-code-nightly/AppRun" "$out/libexec/t3-code-nightly/usr"
      # Icons are installed under $out/share; these AppImage links target the removed usr tree.
      rm -f "$out/libexec/t3-code-nightly/.DirIcon" "$out/libexec/t3-code-nightly/t3code.png"
      rm "$out/libexec/t3-code-nightly/libvulkan.so.1"
      ln -s ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 "$out/libexec/t3-code-nightly/"
      runHook postInstall
    '';
    postFixup = ''
      makeWrapper "$out/libexec/t3-code-nightly/t3code" "$out/bin/t3code" \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
        --prefix PATH : ${
          lib.makeBinPath [
            cloudflared
            git
            gh
          ]
        } \
        --set T3CODE_DISABLE_AUTO_UPDATE 1
      makeWrapper "$out/libexec/t3-code-nightly/t3code" "$out/bin/t3" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
        --prefix PATH : ${
          lib.makeBinPath [
            cloudflared
            git
            gh
          ]
        } \
        --set T3CODE_DISABLE_AUTO_UPDATE 1 \
        --set ELECTRON_RUN_AS_NODE 1 \
        --add-flag "$out/libexec/t3-code-nightly/resources/app.asar/apps/server/dist/bin.mjs"
    '';
  })
