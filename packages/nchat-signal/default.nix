# nchat, with Signal support (HAS_SIGNAL) layered on top of nixpkgs' plain
# `nchat` (Telegram + WhatsApp). Upstream ships Signal off by default because
# enabling it needs libsignal_ffi (a Rust/cargo build) and a second Go
# c-archive, both of which nchat's own CMake normally fetches/builds over the
# network at build time — impossible in the Nix sandbox. So both are instead
# built as ordinary Nix derivations ahead of time and spliced in via a patch,
# mirroring the trick nixpkgs' own nchat package.nix already uses for
# WhatsApp's Go c-archive (go-libs-build.patch / lib/wmchat).
#
# libsignal-ffi's pinned version (0.97.2) happens to already match exactly
# what nchat's vendored mautrix-signal copy requires (lib/sgchat/go/ext/signal
# pkg/libsignalgo/version.go) — same upstream lineage, both vendor from
# mautrix/signal.
{
  lib,
  nchat,
  buildGoModule,
  libsignal-ffi,
  boringssl,
  replaceVars,
}: let
  # Static archive: nchat's C++ link force-loads it whole
  # (-Wl,--whole-archive), which needs a .a, not a .so.
  libsignalFfi = libsignal-ffi.override {withShared = false;};

  # libsignal_ffi.a (a Rust staticlib) never actually links BoringSSL in —
  # see the comment above the linker flags in enable-signal.patch for why.
  # Need the real static libcrypto.a/libssl.a alongside it.
  boringsslStatic = boringssl.override {withShared = false;};

  # The Signal Go c-archive (lib/sgchat/go), prebuilt the same way nixpkgs'
  # nchat.passthru.libcgowm prebuilds WhatsApp's — see that derivation in
  # pkgs/by-name/nc/nchat/package.nix for the origin of this pattern.
  libcgosg = buildGoModule {
    pname = "nchat-libcgosg";
    inherit (nchat) version src;

    sourceRoot = "${nchat.src.name}/lib/sgchat/go";
    vendorHash = "sha256-txtzF/fbTMSvpvYoxjvKckOtMxZV+SZTps3LPKZjqa0=";

    env.CGO_ENABLED = "1";
    buildInputs = [libsignalFfi];

    buildPhase = ''
      runHook preBuild

      mkdir -p $out/
      LIBRARY_PATH=${libsignalFfi}/lib go build -o $out/ -buildmode=c-archive -buildvcs=false
      mv $out/go.a $out/libcgosg.a
      ln -s $out/libcgosg.a $out/libref-cgosg.a
      mv $out/go.h $out/libcgosg.h

      runHook postBuild
    '';
  };
in
  nchat.overrideAttrs (old: {
    pname = "nchat-signal";

    patches =
      old.patches
      ++ [
        (replaceVars ./enable-signal.patch {
          inherit libcgosg libsignalFfi;
          boringsslSsl = "${boringsslStatic}/lib/libssl.a";
          boringsslCrypto = "${boringsslStatic}/lib/libcrypto.a";
        })
      ];

    cmakeFlags = old.cmakeFlags ++ [(lib.cmakeBool "HAS_SIGNAL" true)];

    passthru =
      (old.passthru or {})
      // {inherit libcgosg libsignalFfi boringsslStatic;};
  })
