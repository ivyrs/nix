# AGENTS.md

Guidance for AI agents working in this repo. See `README.md` first for the
overall layout.

## Den — how this flake is wired

This flake is built on [Den](https://github.com/denful/den) (`inputs.den`,
imported via `modules/hosts/declarations.nix`). Every `.nix` file under
`modules/` and `hosts/` is auto-imported by `import-tree` (wired in
`flake.nix`), and files register themselves one of two ways:

- **Plain reusable modules** — `flake.modules.<class>.<name>`, e.g.:

  ```nix
  { flake.modules.nixos.sops = { ... }; }
  ```

  `modules/sops.nix` is the only thing using this form; everything
  else (darwin/service/home-manager concerns) has been converted to the
  form below.

- **`den.aspects.<name>`** — a feature as a function of context
  (`{ host, user }`), holding config for every Nix class it touches at once
  (`nixos`, `darwin`, `homeManager`). `<class>` is one of `nixos`, `darwin`,
  `homeManager`; an aspect can define one, several, or (via `includes`)
  compose other aspects together. This is how almost everything under
  `modules/aspects/` registers.

  - **`den.hosts.<system>.<name>`** (declared per-host, in each
    `hosts/<host>/default.nix`) declares each machine and its users. Den
    turns these into real `darwinConfigurations.*` / `nixosConfigurations.*`
    outputs — there is no hand-written `modules/configurations.nix`
    assembling them.
  - Each host's `default.nix` (`hosts/aspen/`, `hosts/elm/`,
    `hosts/houseplants/`, `hosts/lovecomputer/`) defines that host's own
    `den.aspects.<hostname>` (name-matched to the host, so Den auto-applies
    it) with a `darwin`/`nixos` block and an `includes` list of the aspects
    it wants (services, hardware, etc). Each host's `home.nix` defines its
    `provides.to-users.includes`/`provides.to-users.homeManager` (delivered
    to every user on the host — currently just `ivy`).
  - `modules/users/ivy.nix` defines the shared `ivy` user aspect
    (name-matched to the `ivy` user declared on every host), wiring
    `den.batteries.define-user` + `den.batteries.primary-user` (OS user
    creation, primary-user groups/`system.primaryUser`) **and** the NixOS
    account itself (shell, declarative password hash, the aspen SSH pubkey)
    — genuinely cross-host content that used to be duplicated verbatim in
    elm/houseplants/lovecomputer's `default.nix`.

Implications for edits:
- **Adding a reusable feature**: create a new file under `modules/aspects/`
  (or `modules/hosts/`, `modules/users/`), give it a
  `den.aspects.<name>.<class>` attribute (or `.includes` to compose other
  aspects), picked up automatically by `import-tree`. Aspects are organized
  by feature under `modules/aspects/` rather than target-class directories,
  since a single aspect should configure all targets for that feature.
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

## Four very different targets

`aspen` is nix-darwin + home-manager (macOS, personal machine). `elm`,
`houseplants`, and `lovecomputer` are all plain NixOS, but play different
roles: `elm` is the home server sitting behind the tailnet (Syncthing,
glance, miniflux, pocket-id, vaultwarden, Nextcloud, GoToSocial, Forgejo,
multi-scrobbler — all on bare ports with no public exposure, except glance,
which is exposed as a TLS-terminated Tailscale Service via `tailscale serve`
rather than a bare port); `houseplants` and `lovecomputer` are
both Hetzner VPSes with `networking.firewall.allowedTCPPorts = [80 443]`
open to the real internet — `houseplants` runs Caddy
(`modules/aspects/caddy.nix`) and reverse-proxies each
`houseplants.cloud`/`ivy.rs` hostname to the matching port on
`elm.<tailnet>`; `lovecomputer` runs a second Caddy edge
(`modules/aspects/lovecomputer-caddy.nix`) serving mostly static
sites, plus one reverse-proxy to elm's pocket-id. Every other host only
opens ports on `tailscale0`.

Adding a new elm service that needs public exposure means two edits: the
service itself on elm, and a new `virtualHosts."..."` block in
`modules/aspects/caddy.nix` pointing at its port.

A module meant for one host will generally not evaluate on another (e.g.
`system.defaults` is darwin-only, `boot.loader` is NixOS-only). When adding
something intended to be shared across hosts, check it's platform-neutral
before wiring it into each host's aspect definition.

## Guardrails already left in the code — read before touching

- `hosts/elm/_hardware-configuration.nix` and
  `hosts/{houseplants,lovecomputer}/{_hardware-configuration,_disko}.nix`
  are generated (by `nixos-generate-config` / `nixos-anywhere`); never
  hand-edit them.
- `hosts/elm/default.nix`, `hosts/houseplants/default.nix`, and
  `hosts/lovecomputer/default.nix`: `system.stateVersion` has a "don't fuck
  with this" comment on each — leave it alone even during unrelated
  refactors.
- `modules/hosts/declarations.nix`: `den.default.homeManager.home.stateVersion`
  is "set once, don't bump casually" — same rule, applies to every host
  (hoisted here since it was identical everywhere).
- `networking.firewall.interfaces."tailscale0".allowedTCPPorts` entries on
  elm (glance, vaultwarden, nextcloud, miniflux, etc.) are effectively
  no-ops: Tailscale's own iptables `ts-input` chain accepts all traffic on
  `tailscale0` before NixOS's `networking.firewall` is ever evaluated, so
  every port on elm is already reachable tailnet-wide regardless of these
  lists. Don't treat them as real access control, and don't "fix" a security
  concern by adding one — real per-service restriction needs a Tailscale ACL
  in the admin console, not a NixOS firewall change.
- Comments flagged `verify this` / `confirm this` mark values the user
  hasn't independently confirmed against the real machine — flag rather than
  silently trust when reasoning about them.
- `modules/aspects/homebrew.nix`: `cleanup = "zap"` means anything not
  listed in `brews`/`casks` gets uninstalled on activation — adding a cask
  means adding it here, not installing it out-of-band.
- `secrets/secrets.yaml` is sops-encrypted and safe to commit as-is — never
  write a decrypted value into it directly or into any other tracked file.
  Edit it with `sops secrets/secrets.yaml`; see the README's Secrets section.
- Nix flakes only see git-tracked files. A new file under `modules/`/`hosts/`
  (or `secrets/`) is invisible to `nix eval`/`nix build` until it's at least
  `git add`ed, even uncommitted — a "no matching creation rules found" or
  "attribute ... missing" error after adding a new file usually means this.
- `modules/aspects/glance/_*.nix` are underscore-prefixed **on
  purpose**: import-tree skips them, and they are plain functions/attrsets
  imported explicitly by `glance/default.nix`, not flake-parts modules.
  Conversely, any non-underscored `.nix` file under `modules/`/`hosts/` WILL
  be auto-imported as a flake-parts module and must register via
  `flake.modules.*`/`den.aspects.*` — don't drop a helper file there without
  the underscore. `packages/` is outside `import-tree`'s scan paths
  entirely, so files there (e.g. `packages/glance-agent/default.nix`) don't
  need the underscore convention.
- Shared constants come from `config.flake.lib.meta` (`modules/meta/meta.nix`).
  Read it at the **file level** and close over it — inside a nested
  `({ pkgs, ... }: ...)` block, `config` is the OS/HM config, not the flake's
  (same class of gotcha as the module-arg one above).
- `modules/aspects/glance/default.nix`'s `tailscale-serve-dash`
  systemd unit shells out to the `tailscale serve` CLI rather than using the
  declarative `services.tailscale.serve.services` option — as of tailscaled
  1.98.x that option's JSON config path can only ever produce a plain-HTTP
  `tcp:<port>` listener, never a TLS-terminated one, no matter the backend
  URL scheme given. Don't "simplify" this back to the declarative option; it
  would silently drop glance's TLS cert on `dash.<tailnet>.ts.net`.

## Sanity-checking changes

There's no CI in this repo. Before considering a change done, at minimum run:

```
nix flake check
```

and, if you have access to the target machine, a real rebuild — `just switch`
from the host itself, or `just deploy elm`/`just deploy houseplants`/
`just deploy lovecomputer` from another machine on the tailnet (works fine
unattended/non-interactively; see the README's Usage section). `nix flake
check` alone won't catch every activation-time issue (e.g. Homebrew/darwin-only
assertions on aspen). `darwin-rebuild build --flake .#aspen` / `nixos-rebuild
build --flake .#<host>` (build without activating) is a good middle ground
when you can't activate directly.
