{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
  libx11,
}:
buildGoModule (finalAttrs: {
  pname = "tsui";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "neuralink";
    repo = "tsui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DVkiZc+7XNgj47T1uZg6bnfoMw+0dP4+72AxfCYKcL4=";
  };

  vendorHash = "sha256-FIbkPE5KQ4w7Tc7kISQ7ZYFZAoMNGiVlFWzt8BPCf+A=";

  # Upstream's own flake.nix (not consumed directly here, since it targets
  # an older nixpkgs and un-Nixes the binary's rpath for standalone
  # redistribution — we want the opposite, a normal Nix store closure).
  # Linux clipboard support only; macOS's Cocoa framework is already covered
  # by the default Darwin SDK, no explicit buildInput needed.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [libx11];

  ldflags = ["-X main.Version=${finalAttrs.version}"];

  meta = {
    description = "Elegant TUI for configuring Tailscale";
    homepage = "https://github.com/neuralink/tsui";
    license = lib.licenses.mit;
    mainProgram = "tsui";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
