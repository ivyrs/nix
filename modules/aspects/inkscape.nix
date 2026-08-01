{inputs, ...}: {
  # Inkscape SIGABRTs on startup on aarch64-darwin: librsvg's gdk-pixbuf SVG
  # loader installs as .dylib on Darwin, but gdk-pixbuf only scans for .so,
  # so the loader never registers and icon rendering hits a fatal GTK
  # assertion (nixpkgs#475236). Fix isn't merged yet (nixpkgs#520909) — this
  # overlay pulls just librsvg from the fix branch. Drop this file and the
  # nixpkgs-librsvg-fix flake input once the PR lands in nixpkgs-unstable.
  den.aspects.inkscape = {
    darwin.nixpkgs.overlays = [
      (final: prev: {
        # Only `system` — not `config`: prev.config here is the *resolved*
        # config (already-evaluated values like `rewriteURL = null`), and
        # feeding that back into a fresh `import nixpkgs { config = ...; }`
        # trips its option system (expects a function, not a resolved null).
        librsvg = (import inputs.nixpkgs-librsvg-fix {
          inherit (prev) system;
        }).librsvg;
      })
    ];

    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.inkscape];
    };
  };
}
