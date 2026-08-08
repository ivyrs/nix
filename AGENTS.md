# AGENTS.md

Guidance for AI agents working in this repo. Read `README.md` first — it's
the source of truth for the flake's layout, Den mechanics (`den.hosts`,
`den.aspects`, batteries), and each host's role. This file only adds editing
implications, gotchas, and guardrails that README doesn't cover.

## Editing implications

- **Adding a reusable feature**: create a new file under `modules/aspects/`
  (or `modules/hosts/`, `modules/users/`), give it a
  `den.aspects.<name>.<class>` attribute (or `.includes` to compose other
  aspects), picked up automatically by `import-tree`. Aspects are organized
  by feature under `modules/aspects/` rather than target-class directories,
  since a single aspect should configure all targets for that feature.
  `modules/aspects/` is further split into subdirectories by feature domain
  (`core/`, `desktop/`, `dev/`, `services/`, `shell/`) — that grouping is
  purely for human navigation and has no effect on the `den.aspects.<name>`
  namespace or on `import-tree`, which recurses regardless of depth. It's
  also normal for one aspect to be contributed to from more than one file —
  e.g. `den.aspects.desktop.homeManager` gets packages from both
  `desktop/default.nix` and `desktop/aerc/default.nix`; Den merges them.
- **Using an aspect inside a host**: reference it by name in the host's
  `den.aspects.<hostname>.includes` list (for `nixos`/`darwin`-class
  aspects) or `provides.to-users.includes` (for `homeManager`-class
  aspects) — e.g. `den.aspects.caddy` in `hosts/houseplants/default.nix`.
- **Third-party OS modules** (sops-nix, nix-homebrew, disko, home-manager
  itself) are imported directly into a host aspect's owned-config `imports`,
  e.g. `inputs.sops-nix.darwinModules.sops` in `hosts/aspen/default.nix`.
  Only `home-manager`'s own OS module is handled by Den automatically
  (because `ivy` has `homeManager` in its classes); Den forwards
  `den.aspects.<host>.provides.to-users.homeManager` into
  `home-manager.users.ivy` for you.
- **Module-arg gotcha**: functions nested inside an aspect's owned config
  (e.g. the `({ pkgs, ... }: { ... })` blocks in `hosts/*/default.nix`) are
  evaluated by the underlying `darwinSystem`/`nixosSystem` call, which does
  **not** get `inputs`/`den`/`config` as specialArgs the way the outer
  aspect-definition file does. Reference `inputs`/`config` from the
  **outer** file-level function's arguments via lexical closure — don't
  re-request them as a parameter on the nested function, it'll error with
  `attribute 'inputs' missing` (or `'self' missing` — use `inputs.self`,
  not bare `self`).
- **Standalone (non-Den) rendering**: `modules/meta/home-configurations.nix`
  needs the `den.aspects.home-manager` bundle as a plain home-manager module
  outside any host/user context (for unmanaged machines). It uses Den's own
  `den.lib.aspects.resolve "homeManager" den.aspects.home-manager` helper
  for this — the same mechanism Den's `resolveImports` uses internally to
  extract homeManager modules from a host tree.
- **Don't** build a manual `imports = [ ./foo.nix ./bar.nix ]` list anywhere
  under `modules/`/`hosts/` — that defeats the point of import-tree.

## Host-specific edits

See README's Machines table for each host's role.

Adding a new elm service that needs public exposure means two edits: the
service itself on elm, and a new `virtualHosts."..."` block in
`modules/aspects/caddy.nix` pointing at its port.

A module meant for one host will generally not evaluate on another (e.g.
`system.defaults` is darwin-only, `boot.loader` is NixOS-only). When adding
something intended to be shared across hosts, check it's platform-neutral
before wiring it into each host's aspect definition.

## Guardrails already left in the code — read before touching

- `hosts/elm/_hardware-configuration.nix` and
  `hosts/houseplants/{_hardware-configuration,_disko}.nix`
  are generated (by `nixos-generate-config` / `nixos-anywhere`); never
  hand-edit them.
- `hosts/alder/_hardware-configuration.nix` is now the **real**
  `nixos-generate-config` output from alder's physical Asahi install (no
  longer a placeholder) — the same never-hand-edit rule as elm/houseplants'
  hardware configs applies. `hardware.asahi.extractPeripheralFirmware = true`
  in `hosts/alder/default.nix` with `peripheralFirmwareDirectory =
  /etc/nixos/asahi-firmware` — that directory (containing Apple's
  proprietary `firmware.cpio`) lives only on alder itself, **outside this
  repo**: this repo's Codeberg remote is public, and committing that file
  would redistribute Apple's firmware to anyone who clones it. Because that
  path is outside the flake tree, `nixos-apple-silicon`'s peripheral-firmware
  module (which string-interpolates it into a derivation's `buildCommand`)
  always needs `--impure` to evaluate — on any machine, including alder
  itself, regardless of whether the directory exists there. This is
  permanent/by-design, not a bug to fix away (the upstream module's own docs
  say as much); `nix flake check` won't catch it since it doesn't force
  `config.system.build.toplevel` that deeply, but `just switch`/`just deploy
  alder` already pass `--impure` automatically so you don't need to
  remember it.
- `hosts/elm/default.nix` and `hosts/houseplants/default.nix`:
  `system.stateVersion` has a "don't fuck with this" comment on each —
  leave it alone even during unrelated refactors.
- `modules/hosts/declarations.nix`: `den.default.homeManager.home.stateVersion`
  is "set once, don't bump casually" — same rule, applies to every host
  (hoisted here since it was identical everywhere).
- Service aspects deliberately don't declare
  `networking.firewall.interfaces."tailscale0".allowedTCPPorts`: Tailscale's
  own iptables `ts-input` chain accepts all traffic on `tailscale0` before
  NixOS's `networking.firewall` is ever evaluated, so any such entry would be
  a no-op — every port on a tailscale-server host is already reachable
  tailnet-wide regardless. Don't add one back as a "fix" for a security
  concern — real per-service restriction needs a Tailscale ACL in the admin
  console, not a NixOS firewall change.
- Comments flagged `verify this` / `confirm this` mark values the user
  hasn't independently confirmed against the real machine — flag rather than
  silently trust when reasoning about them.
- `modules/aspects/desktop/mac/homebrew.nix`: `cleanup = "zap"` means
  anything not listed in `brews`/`casks` gets uninstalled on activation —
  adding a cask means adding it here, not installing it out-of-band.
- `secrets/secrets.yaml` is sops-encrypted and safe to commit as-is — never
  write a decrypted value into it directly or into any other tracked file.
  Edit it with `sops secrets/secrets.yaml`; see the README's Secrets section.
- Nix flakes only see git-tracked files. A new file under `modules/`/`hosts/`
  (or `secrets/`) is invisible to `nix eval`/`nix build` until it's at least
  `git add`ed, even uncommitted — a "no matching creation rules found" or
  "attribute ... missing" error after adding a new file usually means this.
- `modules/aspects/services/glance/_*.nix` are underscore-prefixed **on
  purpose**: import-tree skips them, and they are plain functions/attrsets
  imported explicitly by `glance/default.nix`, not flake-parts modules.
  Conversely, any non-underscored `.nix` file under `modules/`/`hosts/` WILL
  be auto-imported as a flake-parts module and must register via
  `flake.modules.*`/`den.aspects.*` — don't drop a helper file there without
  the underscore. `packages/` is outside `import-tree`'s scan paths
  entirely, so files there (e.g. `packages/glance-agent/default.nix`,
  `packages/nokkvi/default.nix`) don't need the underscore convention.
- Shared constants come from `config.flake.lib.meta` (`modules/meta/meta.nix`).
  Read it at the **file level** and close over it — inside a nested
  `({ pkgs, ... }: ...)` block, `config` is the OS/HM config, not the flake's
  (same class of gotcha as the module-arg one above).
- `modules/aspects/services/glance/default.nix`'s `tailscale-serve-dash`
  systemd unit shells out to the `tailscale serve` CLI rather than using the
  declarative `services.tailscale.serve.services` option — as of tailscaled
  1.98.x that option's JSON config path can only ever produce a plain-HTTP
  `tcp:<port>` listener, never a TLS-terminated one, no matter the backend
  URL scheme given. Don't "simplify" this back to the declarative option; it
  would silently drop glance's TLS cert on `dash.<tailnet>.ts.net`.
- Ghostty's theme, lazygit's config file, and zathura's theme are coupled
  across four files for noctalia hosts (alder currently; not aspen, which
  has no noctalia): `desktop/ghostty.nix` sets
  `programs.ghostty.settings.theme` with `lib.mkDefault "Catppuccin Mocha"`,
  `dev/git.nix` sets `programs.lazygit.settings` with `lib.mkDefault {...}`,
  `desktop/zathura.nix` sets `programs.zathura.options` with
  `lib.mkDefault {...}`, and `desktop/noctalia.nix` force-overrides all
  three (`lib.mkForce "noctalia"` / `lib.mkForce {}` / `lib.mkForce {}` +
  `extraConfig = "include noctaliarc"`) so noctalia's own templating can
  supply its generated theme at runtime. Ghostty and lazygit need the
  home-manager-owned file forced empty because noctalia *writes into that
  exact path* (`~/.config/lazygit/config.yml`, ghostty's `noctalia` theme
  file) — a non-empty home-manager symlink there would make that write fail
  with a permission error against the nix store. Zathura is different:
  noctalia writes its generated theme to a sibling file
  (`~/.config/zathura/noctaliarc`), never touching the home-manager-managed
  `zathurarc`, so `zathurarc` just needs an `include noctaliarc` line (via
  `extraConfig`) with `options` forced empty so the static Catppuccin `set`
  lines don't get written after the include and clobber it. If you touch
  any one of these four files, check the others still make sense together.

## Sanity-checking changes

There's no CI in this repo. Before considering a change done, at minimum run:

```
nix flake check
```

and, if you have access to the target machine, a real rebuild — `just switch`
from the host itself, or `just deploy elm`/`just deploy houseplants` from
another machine on the tailnet (works fine unattended/non-interactively; see
the README's Usage section). `nix flake
check` alone won't catch every activation-time issue (e.g. Homebrew/darwin-only
assertions on aspen). `darwin-rebuild build --flake .#aspen` / `nixos-rebuild
build --flake .#<host>` (build without activating) is a good middle ground
when you can't activate directly.

## Committing 

When commiting, DO NOT add any attribution about your tool name or model. 
